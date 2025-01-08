import json
import boto3
import os

def lambda_handler(event, context):
    unconfirmed_subscribers_table = boto3.resource('dynamodb').Table(os.getenv('UNCONFIRMED_SUBSCRIBERS_TABLE_NAME'))
    subscribers_table = boto3.resource('dynamodb').Table(os.getenv('SUBSCRIBERS_TABLE_NAME'))

    if any(var is None for var in [unconfirmed_subscribers_table, subscribers_table]):
        return {"statusCode": 500, "body": json.dumps("Environment variables not set")}
    
    user_uuid = str(event['queryStringParameters']['uuid'])
    email = get_email(unconfirmed_subscribers_table, user_uuid)

    if email is None:
        return {"statusCode": 404, "body": json.dumps("User not found")}
    
    remove_user(subscribers_table, email)

    return {
        'statusCode': 200,
        'body': json.dumps('OK')
    }

def get_email(table, user_uuid: str):
    response = table.get_item(Key={'uuid': user_uuid})

    if 'Item' not in response:
        return None

    return response['Item']['email']

def remove_user(table, email: str):
    table.delete_item(Key={'email': email})
    
    print(f"Deleted user with email: {email}")