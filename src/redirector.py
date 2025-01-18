import os
import boto3
from botocore.exceptions import ClientError
from typing import Tuple
from email.parser import Parser
from quopri import decodestring
import re


def lambda_handler(event, context):
    whitelist = os.getenv("WHITELIST")
    server_sender_email = os.getenv("SENDER_EMAIL")
    bucket_name = os.getenv("EMAIL_BUCKET_NAME")
    subscriptions_table_name = os.getenv("SUBSCRIPTIONS_TABLE_NAME")
    emails_table_name = os.getenv("EMAILS_TABLE_NAME")
    unsubscribe_url = os.getenv("UNSUBSCRIBE_URL")
    valid_topics = os.getenv("VALID_TOPICS")

    if any(
        var is None
        for var in [
            whitelist,
            server_sender_email,
            bucket_name,
            subscriptions_table_name,
            emails_table_name,
            unsubscribe_url,
            valid_topics,
        ]
    ):
        raise ValueError("Environment variables not set")

    whitelist = whitelist.split(",")
    valid_topics = valid_topics.split(",")
    bucket = boto3.resource("s3").Bucket(bucket_name)
    subscriptions_table = boto3.resource("dynamodb").Table(subscriptions_table_name)
    emails_table = boto3.resource("dynamodb").Table(emails_table_name)

    info = event["Records"][0]["ses"]["mail"]
    date = info["commonHeaders"]["date"]
    newsletter_sender = info["source"]
    messageId = info["messageId"]
    subject_body = info["commonHeaders"]["subject"]
    email_body_plain, email_body_html = get_email_body(bucket, messageId)

    if newsletter_sender not in whitelist:
        print("Sender not in whitelist.")
        return {"statusCode": 403, "body": "Forbidden"}

    try:
        topics, email_subject = extract_topics_and_subject(valid_topics, subject_body)
    except Exception as e:
        print(f"Error: {e}")
        reply_to_sender(server_sender_email, newsletter_sender, valid_topics)
        return {"statusCode": 400, "body": "Invalid topics or subject"}

    archive_email(emails_table, messageId, date, newsletter_sender, email_subject, topics)
    subscribers = get_all_users_by_topics(subscriptions_table, topics)

    send_newsletter(
        server_sender_email,
        unsubscribe_url,
        email_subject,
        email_body_plain,
        email_body_html,
        subscribers,
    )

    return {"statusCode": 200, "body": "OK"}


def get_email_body(bucket, messageId: str) -> Tuple[str, str]:
    response = bucket.Object(messageId).get()
    emailRawString = response['Body'].read().decode('utf-8')
    parser = Parser()
    emailString = parser.parsestr(emailRawString)
    if emailString.is_multipart():
        for part in emailString.walk():
            if part.get_content_type() == 'text/plain':
                plain_body = part.get_payload()
            elif part.get_content_type() == 'text/html':
                html_body = part.get_payload()
    else:
        plain_body = emailString.get_payload()
        html_body = emailString.get_payload()

    return decodestring(plain_body).decode("utf-8"), decodestring(html_body).decode("utf-8")


def extract_topics_and_subject(valid_topics: list[str], subject_body: str) -> tuple:
    match = re.match(r"\[(.*?)\]\s*(.+)", subject_body)

    if match:
        topics = match.group(1).split(",")
        topics = [topic.lower().strip() for topic in topics]
        subject = match.group(2)

        if any(topic not in valid_topics for topic in topics):
            raise ValueError("Invalid topics found")
    else:
        raise ValueError("Either no topics found or invalid format")

    return topics, subject


def archive_email(table, 
    messageId: str, 
    date: str, 
    sender: str, 
    subject: str, 
    topics: list[str]
):
    table.put_item(
        Item={
            "messageId": messageId,
            "date": date,
            "sender": sender,
            "subject": subject,
            "topics": topics,
        }
    )


def get_all_users_by_topics(table, topics: list[str]) -> list:
    response = table.scan()
    users = response["Items"]

    return [
        user["email"]
        for user in users
        if any(topic in user["topics"] for topic in topics)
    ]


def append_unsubscribe_link_plain(unsubscribe_url: str, email_body: str) -> str:
    unsubscribe_plain = f"To unsubscribe, go to the following link: {unsubscribe_url}"

    return f"{email_body} {unsubscribe_plain}"


def append_unsubscribe_link_html(unsubscribe_url: str, email_body: str) -> str:
    unsubscribe_html = f'<p style="margin-top: 20px;">To unsubscribe, <a href="{unsubscribe_url}" target="_blank">click here</a>.</p>'

    return f"<div>{email_body}</div>{unsubscribe_html}"


def send_newsletter(
    server_sender_email: str,
    unsubscribe_url: str,
    subject: str,
    email_body_plain: str,
    email_body_html: str,
    recipients: list[str],
):
    ses_client = boto3.client("ses")
    email_body_with_unsubscribe_plain = append_unsubscribe_link_plain(
        unsubscribe_url, email_body_plain
    )
    email_body_with_unsubscribe_html = append_unsubscribe_link_html(
        unsubscribe_url, email_body_html
    )

    try:
        response = ses_client.send_email(
            Source=server_sender_email,
            Destination={
                "ToAddresses": [server_sender_email],
                "BccAddresses": recipients,
            },
            Message={
                "Subject": {"Data": subject},
                "Body": {
                    "Text": {"Data": email_body_with_unsubscribe_plain},
                    "Html": {"Data": email_body_with_unsubscribe_html},
                },
            },
        )

        print(f"Email sent successfully: {response}")
    except ClientError as e:
        print(f"Failed to send email: {e.response['Error']['Message']}")


def reply_to_sender(
    server_sender_email: str, newsletter_sender_email: str, valid_topics: list
):
    ses_client = boto3.client("ses")
    email_body = f"Invalid topics found. Valid topics are: {', '.join(valid_topics)}. Follow the format: [topic1,topic2] Subject"
    subject = "Invalid topics found"

    try:
        response = ses_client.send_email(
            Source=server_sender_email,
            Destination={
                "ToAddresses": [server_sender_email],
                "BccAddresses": [newsletter_sender_email],
            },
            Message={
                "Subject": {"Data": subject},
                "Body": {"Text": {"Data": email_body}},
            },
        )

        print(f"Email sent successfully: {response}")
    except ClientError as e:
        print(f"Failed to send email: {e.response['Error']['Message']}")
