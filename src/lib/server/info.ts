import {
	toSubscriptionItem,
	toConfirmationItem,
	type SubscriptionItem,
	type ConfirmationItem
} from '$lib/types/dynamodbitems';
import { GetItemCommand, type DynamoDBClient } from '@aws-sdk/client-dynamodb';

export async function getItemByEmail(
	client: DynamoDBClient,
	tableName: string,
	email: string
): Promise<SubscriptionItem | null> {
	try {
		const { Item } = await client.send(
			new GetItemCommand({
				TableName: tableName,
				Key: { email: { S: email } }
			})
		);
		if (!Item) return null;

		return toSubscriptionItem(Item);
	} catch (e: unknown) {
		throw new Error(
			`Failed to get item from DynamoDB table (${tableName}): ${(e as Error).message}`
		);
	}
}

export async function getItemByUUID(
	client: DynamoDBClient,
	tableName: string,
	uuid: string
): Promise<ConfirmationItem | null> {
	try {
		const { Item } = await client.send(
			new GetItemCommand({
				TableName: tableName,
				Key: { uuid: { S: uuid } }
			})
		);
		if (!Item) return null;

		return toConfirmationItem(Item);
	} catch (e: unknown) {
		throw new Error(
			`Failed to get item from DynamoDB table (${tableName}): ${(e as Error).message}`
		);
	}
}
