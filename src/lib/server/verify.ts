import { DynamoDBClient, PutItemCommand, type PutItemCommandInput } from '@aws-sdk/client-dynamodb';
import { marshall } from '@aws-sdk/util-dynamodb';
import { SESClient, SendEmailCommand, type SendEmailCommandInput } from '@aws-sdk/client-ses';

export async function createVerification(
	client: DynamoDBClient,
	tableName: string,
	email: string,
	topics: string[],
	uuid: string,
	ttl: number
): Promise<void> {
	const ttlValue = Math.floor(Date.now() / 1000) + ttl;
	const params: PutItemCommandInput = {
		TableName: tableName,
		Item: marshall({
			uuid,
			email,
			topics,
			ttl: ttlValue
		})
	};

	try {
		await client.send(new PutItemCommand(params));
	} catch (e: unknown) {
		throw new Error(`Failed to put item in DynamoDB table (${tableName}): ${(e as Error).message}`);
	}
}

export async function sendConfirmationEmail(
	client: SESClient,
	senderEmail: string,
	verifyUrl: string,
	recipient: string,
	subOrUnsub: 'sub' | 'unsub'
): Promise<void> {
	const keyword = subOrUnsub === 'sub' ? 'Subscribe' : 'Unsubscribe';
	const keywordLower = keyword.toLowerCase();
	const linker = subOrUnsub === 'sub' ? 'to' : 'from';

	const emailBodyPlain = `To ${keywordLower}, go to the following link: ${verifyUrl}`;
	const emailBodyHtml = `<p style="margin-top: 20px;">To ${keywordLower}, <a href="${verifyUrl}" target="_blank">click here</a>.</p>`;
	const subject = `${keyword} ${linker} the newsletter`;

	const params: SendEmailCommandInput = {
		Source: senderEmail,
		Destination: {
			ToAddresses: [senderEmail],
			BccAddresses: [recipient]
		},
		Message: {
			Subject: {
				Data: subject
			},
			Body: {
				Text: {
					Data: emailBodyPlain
				},
				Html: {
					Data: emailBodyHtml
				}
			}
		}
	};

	try {
		await client.send(new SendEmailCommand(params));
	} catch (e: unknown) {
		throw new Error(
			`Failed to send email FROM (${senderEmail}) TO (${recipient}): ${(e as Error).message}`
		);
	}
}
