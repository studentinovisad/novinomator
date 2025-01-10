// See https://svelte.dev/docs/kit/types#app.d.ts

import type { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import type { SESClient } from '@aws-sdk/client-ses';

// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		interface Locals {
			client: {
				dynamodb: DynamoDBClient;
				ses: SESClient;
			};
		}
		// interface PageData {}
		// interface PageState {}
		// interface Platform {}
	}
}

export {};
