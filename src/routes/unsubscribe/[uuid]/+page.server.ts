import { env } from '$env/dynamic/private';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { getItemByEmail, getItemByUUID } from '$lib/server/info';
import { deleteItemByEmail, deleteItemByUUID } from '$lib/server/delete';
import { updateItemByEmail } from '$lib/server/update';

export const load: PageServerLoad = async ({ locals, params }) => {
	try {
		const { client } = locals;
		const { uuid } = params;
		const tableName = env.SUBSCRIPTIONS_TABLE_NAME;
		const confirmTableName = env.CONFIRM_UNSUBSCRIPTIONS_TABLE_NAME;

		if (!tableName || tableName === '' || !confirmTableName || confirmTableName === '') {
			throw new Error(
				'Missing SUBSCRIPTIONS_TABLE_NAME and CONFIRM_UNSUBSCRIPTIONS_TABLE_NAME env vars'
			);
		}

		const confirmUserInfo = await getItemByUUID(client.dynamodb, confirmTableName, uuid);
		if (!confirmUserInfo) {
			return fail(410, {
				message: 'Confirmation expired'
			});
		}

		const { email, topics: confirmTopics } = confirmUserInfo;
		const userInfo = await getItemByEmail(client.dynamodb, tableName, email);
		const userTopics = userInfo ? userInfo.topics : [];
		const topics = userTopics.filter((t) => !confirmTopics.includes(t));

		if (topics.length === 0) {
			await deleteItemByEmail(client.dynamodb, tableName, email);
		} else {
			await updateItemByEmail(client.dynamodb, tableName, email, topics);
		}

		await deleteItemByUUID(client.dynamodb, confirmTableName, uuid);
	} catch (e: unknown) {
		console.error(`Failed to unsubscribe: ${(e as Error).message}`);
		return fail(500, {
			message: 'Internal Server Error'
		});
	}

	return {
		message: 'Successfully unsubscribed'
	};
};
