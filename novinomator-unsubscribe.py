import boto3
import os

def lambda_handler(event, context):
    unconfirmed_subscribers_table_name = os.getenv("UNCONFIRMED_SUBSCRIBERS_TABLE_NAME")
    subscribers_table_name = os.getenv("SUBSCRIBERS_TABLE_NAME")
    
    if any(var is None for var in [unconfirmed_subscribers_table_name, subscribers_table_name]):
        return {"statusCode": 500, "body": "Environment variables not set"}
    
    unconfirmed_subscribers_table = boto3.resource("dynamodb").Table(unconfirmed_subscribers_table_name)
    subscribers_table = boto3.resource("dynamodb").Table(subscribers_table_name)
    
    user_uuid = str(event["queryStringParameters"]["uuid"])
    email = get_email(unconfirmed_subscribers_table, user_uuid)

    if email is None:
        return {"statusCode": 404, "body": "User not found"}
    
    remove_user(subscribers_table, email)

    return {
        "statusCode": 200,
        "body": "OK"
    }

def get_email(table, user_uuid: str):
    response = table.get_item(Key={"uuid": user_uuid})

    if "Item" not in response:
        return None

    return response["Item"]["email"]

def remove_user(table, email: str):
    table.delete_item(Key={"email": email})
    
    print(f"Deleted user with email: {email}")