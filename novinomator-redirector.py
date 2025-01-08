import json
import os
import boto3
from botocore.exceptions import ClientError
import re


def lambda_handler(event, context):
    whitelist = os.getenv("WHITELIST")
    whitelist = whitelist.split(",")
    sender_email = os.getenv('SENDER_EMAIL')
    bucket = boto3.resource('s3').Bucket(os.getenv('BUCKET_NAME'))
    table = boto3.resource('dynamodb').Table(os.getenv('SUBSCRIBERS_TABLE_NAME'))
    unsubscribe_url = os.getenv('UNSUBSCRIBE_URL')

    if any(var is None for var in [whitelist, sender_email, unsubscribe_url, bucket, table]):
        return {"statusCode": 500, "body": json.dumps("Environment variables not set")}

    info = event["Records"][0]["ses"]["mail"]
    messageId = info["messageId"]
    emailInfo = get_email_info(messageId, bucket)
    sender = info["source"]

    if sender not in whitelist:
        return {"statusCode": 403, "body": json.dumps("Forbidden")}

    match = re.search(
        r'Content-Type: text/plain; charset="UTF-8"\s+(.*?)\s+--', emailInfo, re.DOTALL
    )

    if match:
        email_body = match.group(1).strip()
    else:
        email_body = "No text content found in the email."

    topics = [info["commonHeaders"]["subject"]]
    email_subject = info["commonHeaders"]["subject"]
    subscribers = get_all_users_by_topics(topics, table)

    send_newsletter(sender_email, unsubscribe_url, email_subject, email_body, subscribers)

    return {"statusCode": 200, "body": json.dumps("OK")}


def get_email_info(messageId: str, bucket) -> str:
    obj = bucket.Object(messageId)
    response = obj.get()
    email_info = response['Body'].read().decode('utf-8')
    
    return email_info


def get_all_users_by_topics(topics: list, table) -> list:
    response = table.scan()
    users = response['Items']

    return [
        user['email'] for user in users 
        if any(topic in user['subscribed_topics'] for topic in topics)
    ]


def append_unsubscribe_link_html(unsubscribe_url: str, body: str) -> str:
    unsubscribe_html = f'<p style="margin-top: 20px;">To unsubscribe, <a href="{unsubscribe_url}" target="_blank">click here</a>.</p>'

    return f"<div>{body}</div>{unsubscribe_html}"


def send_newsletter(sender_email: str, unsubscribe_url: str, subject: str, body: str, recipients: list):
    ses_client = boto3.client("ses")
    email_body_with_unsubscribe_html = append_unsubscribe_link_html(unsubscribe_url, body)

    try:
        response = ses_client.send_email(
            Source=sender_email,
            Destination={
                "BccAddresses": recipients
            },
            Message={
                "Subject": {"Data": subject},
                "Body": {
                    "Html": {"Data": email_body_with_unsubscribe_html}
                },
            }
        )

        print(f"Email sent successfully: {response}")
    except ClientError as e:
        print(f"Failed to send email: {e.response['Error']['Message']}")
