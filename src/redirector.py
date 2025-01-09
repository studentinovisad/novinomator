import os
import boto3
from botocore.exceptions import ClientError
import re


def lambda_handler(event, context):
    whitelist = os.getenv("WHITELIST")
    server_sender_email = os.getenv("SENDER_EMAIL")
    bucket_name = os.getenv("BUCKET_NAME")
    table_name = os.getenv("SUBSCRIPTIONS_TABLE_NAME")
    unsubscribe_url = os.getenv("UNSUBSCRIBE_URL")
    valid_topics = os.getenv("VALID_TOPICS")

    if any(var is None for var in [whitelist, server_sender_email, bucket_name, table_name, unsubscribe_url, valid_topics]):
        return {"statusCode": 500, "body": "Environment variables not set"}
    
    whitelist = whitelist.split(",")
    valid_topics = valid_topics.split(",")
    bucket = boto3.resource("s3").Bucket(bucket_name)
    table = boto3.resource("dynamodb").Table(table_name)

    info = event["Records"][0]["ses"]["mail"]
    messageId = info["messageId"]
    emailInfo = get_email_info(bucket, messageId)
    newsletter_sender = info["source"]

    if newsletter_sender not in whitelist:
        return {"statusCode": 403, "body": "Forbidden"}

    match = re.search(
        r'Content-Type: text/plain; charset="UTF-8"\s+(.*?)\s+--', emailInfo, re.DOTALL
    )

    if match:
        email_body_plain = match.group(1).strip()
    else:
        email_body_plain = "No plain text content found in the email."

    match = re.search(
        r'Content-Type: text/html; charset="UTF-8"\s+(.*?)\s+--', emailInfo, re.DOTALL
    )

    if match:
        email_body_html = match.group(1).strip()
    else:
        email_body_html = "No text content found in the email."

    subject_body = info["commonHeaders"]["subject"]
    topics, email_subject = extract_topics_and_subject(valid_topics, subject_body)

    if topics == [] or email_subject == "":
        reply_to_sender(server_sender_email, newsletter_sender, valid_topics)

        return {"statusCode": 400, "body": "Invalid topics or subject"}

    subscribers = get_all_users_by_topics(table, topics)

    send_newsletter(server_sender_email, unsubscribe_url, email_subject, email_body_plain, email_body_html, subscribers)

    return {"statusCode": 200, "body": "OK"}


def get_email_info(bucket, messageId: str) -> str:
    obj = bucket.Object(messageId)
    response = obj.get()
    email_info = response["Body"].read().decode("utf-8")
    
    return email_info

def extract_topics_and_subject(valid_topics: list, subject_body: str) -> tuple:
    match = re.match(r"\[(.*?)\]\s*(.+)", subject_body)

    if match:
        topics = match.group(1).split(",")
        topics = [topic.toLowerCase().strip() for topic in topics]
        subject = match.group(2)

        if any(topic not in valid_topics for topic in topics):
            print("Invalid topic found")
            return [], ""
    else:
        print("No match found")
        return [], ""
    
    return topics, subject


def get_all_users_by_topics(table, topics: list) -> list:
    response = table.scan()
    users = response["Items"]

    return [
        user["email"] for user in users 
        if any(topic in user["subscribed_topics"] for topic in topics)
    ]


def append_unsubscribe_link_plain(unsubscribe_url: str, email_body: str) -> str:
    unsubscribe_plain = f'To unsubscribe, go to the following link: {unsubscribe_url}'

    return f"{email_body} {unsubscribe_plain}"


def append_unsubscribe_link_html(unsubscribe_url: str, email_body: str) -> str:
    unsubscribe_html = f'<p style="margin-top: 20px;">To unsubscribe, <a href="{unsubscribe_url}" target="_blank">click here</a>.</p>'

    return f"<div>{email_body}</div>{unsubscribe_html}"


def send_newsletter(server_sender_email: str, unsubscribe_url: str, subject: str, email_body_plain: str, email_body_html: str, recipients: list):
    ses_client = boto3.client("ses")
    email_body_with_unsubscribe_plain = append_unsubscribe_link_plain(unsubscribe_url, email_body_plain)
    email_body_with_unsubscribe_html = append_unsubscribe_link_html(unsubscribe_url, email_body_plain)

    try:
        response = ses_client.send_email(
            Source=server_sender_email,
            Destination={
                "ToAddresses": [server_sender_email],
                "BccAddresses": recipients
            },
            Message={
                "Subject": {"Data": subject},
                "Body": {
                    "Text": {"Data": email_body_with_unsubscribe_plain},
                    "Html": {"Data": email_body_with_unsubscribe_html}
                },
            }
        )

        print(f"Email sent successfully: {response}")
    except ClientError as e:
        print(f"Failed to send email: {e.response["Error"]["Message"]}")


def reply_to_sender(server_sender_email: str, newsletter_sender_email: str, valid_topics: list):
    ses_client = boto3.client("ses")
    email_body = f"Invalid topics found. Valid topics are: {", ".join(valid_topics)}. Follow the format: [topic1,topic2] Subject"
    subject = "Invalid topics found"

    try:
        response = ses_client.send_email(
            Source=server_sender_email,
            Destination={
                "ToAddresses": [server_sender_email],
                "BccAddresses": [newsletter_sender_email]
            },
            Message={
                "Subject": {"Data": subject},
                "Body": {
                    "Text": {"Data": email_body}
                },
            }
        )

        print(f"Email sent successfully: {response}")
    except ClientError as e:
        print(f"Failed to send email: {e.response["Error"]["Message"]}")