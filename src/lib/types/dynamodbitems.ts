export type SubscriptionItem = {
	email: string;
	topics: string[];
};

export function isSubscriptionItem(data: any): data is SubscriptionItem {
	if (
		typeof data !== 'object' ||
		data === null ||
		typeof data.email !== 'string' ||
		!Array.isArray(data.topics) ||
		!data.topics.every((topic: any) => typeof topic === 'string')
	) {
		return false;
	} else {
		return true;
	}
}

export type ConfirmationItem = {
	uuid: string;
	email: string;
	topics: string[];
	ttl: number;
};

export function isConfirmationItem(data: any): data is ConfirmationItem {
	if (
		typeof data !== 'object' ||
		data === null ||
		typeof data.uuid !== 'string' ||
		typeof data.email !== 'string' ||
		!Array.isArray(data.topics) ||
		!data.topics.every((topic: any) => typeof topic === 'string') ||
		typeof data.ttl !== 'number'
	) {
		return false;
	} else {
		return true;
	}
}
