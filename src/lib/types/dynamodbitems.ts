import type { AttributeValue } from '@aws-sdk/client-dynamodb';

export type SubscriptionItem = {
	email: string;
	topics: string[];
};

export function toSubscriptionItem(data: Record<string, AttributeValue>): SubscriptionItem {
	if (
		data === null ||
		data === undefined ||
		typeof data !== 'object' ||
		typeof data.email !== 'object' ||
		typeof data.email.S !== 'string' ||
		typeof data.topics !== 'object' ||
		!Array.isArray(data.topics.SS) ||
		!data.topics.SS.every((topic: any) => typeof topic === 'string')
	) {
		throw new Error(`Invalid item type (subscription): ${JSON.stringify(data)}`);
	}

	return {
		email: data.email.S,
		topics: data.topics.SS
	};
}

export type ConfirmationItem = {
	uuid: string;
	email: string;
	topics: string[];
	ttl: number;
};

export function toConfirmationItem(data: Record<string, AttributeValue>): ConfirmationItem {
	if (
		data === null ||
		data === undefined ||
		typeof data !== 'object' ||
		typeof data.uuid !== 'object' ||
		typeof data.uuid.S !== 'string' ||
		typeof data.email !== 'object' ||
		typeof data.email.S !== 'string' ||
		typeof data.topics !== 'object' ||
		!Array.isArray(data.topics.SS) ||
		!data.topics.SS.every((topic: any) => typeof topic === 'string') ||
		typeof data.ttl !== 'object' ||
		typeof data.ttl.N !== 'string'
	) {
		throw new Error(`Invalid item type (subscription): ${JSON.stringify(data)}`);
	}

	let ttl: number;
	try {
		ttl = Number.parseInt(data.ttl.N);
	} catch (e: unknown) {
		throw new Error(`Failed to convert TTL string to number: ${(e as Error).message}`);
	}

	return {
		uuid: data.uuid.S,
		email: data.email.S,
		topics: data.topics.SS,
		ttl
	};
}
