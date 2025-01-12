import { env } from '$env/dynamic/private';
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { getItemByEmail, getItemByUUID } from '$lib/server/info';
import { deleteItemByUUID } from '$lib/server/delete';
import { updateItemByEmail } from '$lib/server/update';

export const load: PageServerLoad = async ({ locals, params }) => {
	try {
		const { client } = locals;
		const { uuid } = params;
		const tableName = env.SUBSCRIPTIONS_TABLE_NAME;
		const confirmTableName = env.CONFIRM_SUBSCRIPTIONS_TABLE_NAME;

		if (!tableName || tableName === '' || !confirmTableName || confirmTableName === '') {
			throw new Error(
				'Missing SUBSCRIPTIONS_TABLE_NAME and CONFIRM_SUBSCRIPTIONS_TABLE_NAME env vars'
			);
		}

		const confirmUserInfo = await getItemByUUID(client.dynamodb, confirmTableName, uuid);
		if (!confirmUserInfo) {
			return error(410, {
				message: 'Confirmation expired'
			});
		}

		const { email, topics: confirmTopics } = confirmUserInfo;
		const userInfo = await getItemByEmail(client.dynamodb, tableName, email);
		const userTopics = userInfo ? userInfo.topics : [];
		const topics = [...new Set([...confirmTopics, ...userTopics])];

		await updateItemByEmail(client.dynamodb, tableName, email, topics);
		await deleteItemByUUID(client.dynamodb, confirmTableName, uuid);
	} catch (e: unknown) {
		console.error(`Failed to subscribe: ${(e as Error).message}`);
		return error(500, {
			message: `Internal Server Error: ${(e as Error).message}`
		});
	}

	return {
		message: 'Successfully subscribed'
	};
};
