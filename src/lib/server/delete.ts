import { DeleteItemCommand, type DynamoDBClient } from '@aws-sdk/client-dynamodb';

export async function deleteItemByEmail(
	client: DynamoDBClient,
	tableName: string,
	email: string
): Promise<void> {
	try {
		await client.send(
			new DeleteItemCommand({
				TableName: tableName,
				Key: { email: { S: email } }
			})
		);
	} catch (e: unknown) {
		throw new Error(
			`Failed to delete item from DynamoDB table (${tableName}): ${(e as Error).message}`
		);
	}
}

export async function deleteItemByUUID(
	client: DynamoDBClient,
	tableName: string,
	uuid: string
): Promise<void> {
	try {
		await client.send(
			new DeleteItemCommand({
				TableName: tableName,
				Key: { uuid: { S: uuid } }
			})
		);
	} catch (e: unknown) {
		throw new Error(
			`Failed to delete item from DynamoDB table (${tableName}): ${(e as Error).message}`
		);
	}
}
