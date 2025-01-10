import { UpdateItemCommand, type DynamoDBClient } from '@aws-sdk/client-dynamodb';

export async function updateItemByEmail(
	client: DynamoDBClient,
	tableName: string,
	email: string,
	topics: string[]
): Promise<void> {
	try {
		await client.send(
			new UpdateItemCommand({
				TableName: tableName,
				Key: {
					email: { S: email }
				},
				UpdateExpression: 'SET topics = :topics',
				ExpressionAttributeValues: {
					':topics': { SS: topics }
				}
			})
		);
	} catch (e: unknown) {
		throw new Error(`Failed to put item in DynamoDB table (${tableName}): ${(e as Error).message}`);
	}
}
