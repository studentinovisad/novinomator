import { env } from '$env/dynamic/private';
import { fail, type Actions } from '@sveltejs/kit';
import { v4 as uuidv4 } from 'uuid';
import { createVerification, sendConfirmationEmail } from '$lib/server/verify';
import { superValidate } from 'sveltekit-superforms';
import { zod } from 'sveltekit-superforms/adapters';
import { formSchema } from './schema';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
	const form = await superValidate(zod(formSchema));
	const topics = env.TOPICS?.toLowerCase().split(',') ?? [];

	return {
		form,
		topics
	};
};

export const actions: Actions = {
	default: async ({ request, locals }) => {
		const form = await superValidate(request, zod(formSchema));
		if (!form.valid) {
			return fail(400, {
				form,
				message: 'Invalid form inputs'
			});
		}
		const { email, topics } = form.data;

		try {
			const tableName = env.CONFIRM_SUBSCRIPTIONS_TABLE_NAME;
			const senderEmail = env.SENDER_EMAIL;
			const origin = env.ORIGIN;
			const ttlS = env.VERIFY_TTL;

			if (
				!tableName ||
				tableName === '' ||
				!senderEmail ||
				senderEmail === '' ||
				!origin ||
				origin === '' ||
				!ttlS ||
				ttlS === ''
			) {
				throw new Error(
					'Missing CONFIRM_SUBSCRIPTIONS_TABLE_NAME, SENDER_EMAIL, ORIGIN and VERIFY_TTL env vars'
				);
			}

			const { client } = locals;
			const uuid = uuidv4();
			const ttl = Number.parseInt(ttlS);
			await createVerification(client.dynamodb, tableName, email, topics, uuid, ttl);

			const verifyUrl = `${origin}/subscribe/${uuid}`;
			await sendConfirmationEmail(client.ses, senderEmail, verifyUrl, email, 'sub');
		} catch (e: unknown) {
			console.error(`Failed to send confirmation email: ${(e as Error).message}`);
			return fail(500, {
				form,
				message: `Internal Server Error: ${(e as Error).message}`
			});
		}

		return {
			form,
			message: `Successfully sent confirmation email to ${email} for topics: ${topics}`
		};
	}
};
