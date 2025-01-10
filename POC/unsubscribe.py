import boto3
import os


def lambda_handler(event, context):
    confirm_unsubscriptions_table_name = os.getenv("CONFIRM_UNSUBSCRIPTIONS_TABLE_NAME")
    subscriptions_table_name = os.getenv("SUBSCRIPTIONS_TABLE_NAME")

    if any(
        var is None
        for var in [confirm_unsubscriptions_table_name, subscriptions_table_name]
    ):
        return {"statusCode": 500, "body": "Environment variables not set"}

    unconfirmed_subscribers_table = boto3.resource("dynamodb").Table(
        confirm_unsubscriptions_table_name
    )
    subscribers_table = boto3.resource("dynamodb").Table(subscriptions_table_name)

    user_uuid = str(event["queryStringParameters"]["uuid"])
    topics_to_remove = event["queryStringParameters"]["subscribed_topics"]

    try:
        user_info = get_user_info(unconfirmed_subscribers_table, user_uuid)
    except Exception as e:
        print(f"Error: {e}")
        return {"statusCode": 404, "body": "User not found"}

    remove_user_topics(subscribers_table, user_info, topics_to_remove)

    return {"statusCode": 200, "body": "OK"}


def get_user_info(table, user_uuid: str) -> dict:
    response = table.get_item(Key={"uuid": user_uuid})

    if "Item" not in response:
        raise Exception(f"User with uuid: {user_uuid} not found")

    return response["Item"]


def remove_user_topics(table, user_info: dict, topics_to_remove: list[str]):
    user_info["subscribed_topics"] = set(user_info["subscribed_topics"]) - set(
        topics_to_remove
    )

    if user_info["subscribed_topics"]:
        table.update_item(
            Key={"email": user_info["email"]},
            UpdateExpression="SET subscribed_topics = :topics",
            ExpressionAttributeValues={":topics": user_info["subscribed_topics"]},
        )
        print(f"Removed topics from user with email: {user_info['email']}")
    else:
        table.delete_item(Key={"email": user_info["email"]})
        print(f"Deleted user with email: {user_info['email']}")
