import uuid
import os
import boto3
import time
from botocore.exceptions import ClientError


def lambda_handler(event, context):
    table_name = os.getenv("CONFIRM_SUBSCRIPTIONS_TABLE_NAME")
    server_sender_email = os.getenv("SENDER_EMAIL")
    subscribe_url = os.getenv("SUBSCRIBE_URL")
    ttl = os.getenv("TTL")

    if any(var is None for var in [table_name, server_sender_email, subscribe_url, ttl]):
        return {"statusCode": 500, "body": "Environment variables not set"}
    
    table = boto3.resource("dynamodb").Table(table_name)
    recipient = event["queryStringParameters"]["email"]
    topics = event["queryStringParameters"]["topics"]
    recipient_uuid = str(uuid.uuid4())

    add_user(table, recipient, topics, recipient_uuid, ttl)
    send_confirmation_email(server_sender_email, subscribe_url, recipient, recipient_uuid)

    return {
        "statusCode": 200,
        "body": "OK"
    }


def add_user(table, email: str, topics: list, recipient_uuid: str, ttl: int):
    table.put_item(
        Item={
            "uuid": recipient_uuid,
            "email": email,
            "subscribed_topics": topics,
            "ttl": int(time.time()) + int(ttl)
        }
    )

    print(f"User {email} added with topics: {topics}")


def send_confirmation_email(server_sender_email:str, subscribe_url: str, recipient: str, recipient_uuid: str):
    ses_client = boto3.client("ses")
    email_body = f'<p style="margin-top: 20px;">To subscribe, <a href="{subscribe_url}_{recipient_uuid}" target="_blank">click here</a>.</p>'
    subject = "Subscribe to the newsletter"

    try:
        response = ses_client.send_email(
            Source=server_sender_email,
            Destination={
                "BccAddresses": [recipient]
            },
            Message={
                "Subject": {"Data": subject},
                "Body": {
                    "Html": {"Data": email_body}
                },
            }
        )

        print(f"Email sent successfully: {response}")
    except ClientError as e:
        print(f"Failed to send email: {e.response["Error"]["Message"]}")
