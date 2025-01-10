import {
	isSubscriptionItem,
	isConfirmationItem,
	type SubscriptionItem,
	type ConfirmationItem
} from '$lib/types/dynamodbitems';
import { DynamoDBClient, GetItemCommand } from '@aws-sdk/client-dynamodb';
import { unmarshall } from '@aws-sdk/util-dynamodb';

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

		const data = unmarshall(Item);
		if (!isSubscriptionItem(data)) {
			throw new Error('Invalid item type');
		}

		return data;
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

		const data = unmarshall(Item);
		if (!isConfirmationItem(data)) {
			throw new Error('Invalid item type');
		}

		return data;
	} catch (e: unknown) {
		throw new Error(
			`Failed to get item from DynamoDB table (${tableName}): ${(e as Error).message}`
		);
	}
}
