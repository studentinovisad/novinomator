import uuid
import os
import boto3
import time
from botocore.exceptions import ClientError


def lambda_handler(event, context):
    table_name = os.getenv("CONFIRM_UNSUBSCRIPTIONS_TABLE_NAME")
    server_sender_email = os.getenv("SENDER_EMAIL")
    unsubscribe_url = os.getenv("UNSUBSCRIBE_URL")
    ttl = os.getenv("TTL")

    if any(var is None for var in [table_name, server_sender_email, unsubscribe_url, ttl]):
        return {"statusCode": 500, "body": "Environment variables not set"}

    table = boto3.resource("dynamodb").Table(table_name)
    recipient = event["queryStringParameters"]["email"]
    recipient_uuid = str(uuid.uuid4())

    add_user(table, recipient, recipient_uuid, ttl)
    send_confirmation_email(server_sender_email, unsubscribe_url, recipient, recipient_uuid)

    return {
        "statusCode": 200,
        "body": "OK"
    }


def add_user(table, email: str, recipient_uuid: str, ttl: int):
    table.put_item(
        Item={
            "email": email,
            "uuid": recipient_uuid,
            "ttl": int(time.time()) + int(ttl)
        }
    )

    print(f"User {email} added")


def send_confirmation_email(server_sender_email:str, unsubscribe_url:str, recipient: str, recipient_uuid: str):
    ses_client = boto3.client("ses")
    email_body = f'<p style="margin-top: 20px;">To unsubscribe, <a href="{unsubscribe_url}_{recipient_uuid}" target="_blank">click here</a>.</p>'
    subject = "Unsubscribe from our newsletter"

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
