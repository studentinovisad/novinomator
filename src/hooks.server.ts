import { env } from '$env/dynamic/private';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { SESClient } from '@aws-sdk/client-ses';
import type { Handle } from '@sveltejs/kit';

const region = env.AWS_REGION;
const client = {
	dynamodb: new DynamoDBClient({ region }),
	ses: new SESClient({ region })
};

export const handle: Handle = async ({ event, resolve }) => {
	event.locals.client = client;
	return resolve(event);
};
