import boto3
import os


def lambda_handler(event, context):
    confirm_subscriptions_table_name = os.getenv("CONFIRM_SUBSCRIPTIONS_TABLE_NAME")
    subscriptions_table_name = os.getenv("SUBSCRIPTIONS_TABLE_NAME")
    
    if any(var is None for var in [confirm_subscriptions_table_name, subscriptions_table_name]):
        return {"statusCode": 500, "body": "Environment variables not set"}
    
    unconfirmed_subscribers_table = boto3.resource("dynamodb").Table(confirm_subscriptions_table_name)
    subscribers_table = boto3.resource("dynamodb").Table(subscriptions_table_name)
    
    user_uuid = str(event["queryStringParameters"]["uuid"])

    try:
        email = get_email(unconfirmed_subscribers_table, user_uuid)
    except Exception as e:
        print(f"Error: {e}")
        return {"statusCode": 404, "body": "User not found"}
    
    remove_user(subscribers_table, email)

    return {
        "statusCode": 200,
        "body": "OK"
    }


def get_email(table, user_uuid: str):
    response = table.get_item(Key={"uuid": user_uuid})

    if "Item" not in response:
        raise Exception(f"User with uuid: {user_uuid} not found")

    return response["Item"]["email"]


def remove_user(table, email: str):
    table.delete_item(Key={"email": email})
    
    print(f"Deleted user with email: {email}")