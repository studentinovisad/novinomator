import json
import boto3
import os


def lambda_handler(event, context):
    unconfirmed_subscribers_table = boto3.resource('dynamodb').Table(os.getenv('UNCONFIRMED_SUBSCRIBERS_TABLE_NAME'))
    subscribers_table = boto3.resource('dynamodb').Table(os.getenv('SUBSCRIBERS_TABLE_NAME'))

    if any(var is None for var in [unconfirmed_subscribers_table, subscribers_table]):
        return {"statusCode": 500, "body": json.dumps("Environment variables not set")}
    
    user_uuid = str(event["queryStringParameters"]["uuid"])
    user_info = get_user(unconfirmed_subscribers_table, user_uuid)

    if user_info is None:
        return {"statusCode": 404, "body": json.dumps("User not found")}
    
    remove_user(unconfirmed_subscribers_table, user_info["uuid"])
    add_user(subscribers_table, user_info)

    return {"statusCode": 200, "body": json.dumps("OK")}


def get_user(table, user_uuid: str):
    response = table.get_item(Key={"uuid": user_uuid})

    if "Item" not in response:
        return None

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
    
    print(f"Added user with email: {user_info['email']}")
