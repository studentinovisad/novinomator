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
        user_info = get_user(unconfirmed_subscribers_table, user_uuid)
    except Exception as e:
        print(f"Error: {e}")
        return {"statusCode": 404, "body": "User not found"}
    
    remove_user(unconfirmed_subscribers_table, user_info["uuid"])
    add_user(subscribers_table, user_info)

    return {"statusCode": 200, "body": "OK"}


def get_user(table, user_uuid: str):
    response = table.get_item(Key={"uuid": user_uuid})

    if "Item" not in response:
        raise Exception(f"User with uuid: {user_uuid} not found")

    return response["Item"]


def remove_user(table, user_uuid: str):
    table.delete_item(Key={"uuid": user_uuid})

    print(f"Deleted user with uuid: {user_uuid}")


def add_user(table, user_info: dict):
    table.put_item(
        Item={
            "email": user_info["email"],
            "subscribed_topics": user_info["subscribed_topics"],
        }
    )
    
    print(f"Added user with email: {user_info["email"]}")
