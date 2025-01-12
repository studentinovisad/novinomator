import { PutItemCommand, type DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { SendEmailCommand, type SESClient } from '@aws-sdk/client-ses';

export async function createVerification(
	client: DynamoDBClient,
	tableName: string,
	email: string,
	topics: string[],
	uuid: string,
	ttl: number
): Promise<void> {
	try {
		const ttlS = (Math.floor(Date.now() / 1000) + ttl).toString();
		await client.send(
			new PutItemCommand({
				TableName: tableName,
				Item: {
					uuid: { S: uuid },
					email: { S: email },
					topics: { SS: topics },
					ttl: { N: ttlS }
				}
			})
		);
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
	try {
		const keyword = subOrUnsub === 'sub' ? 'Subscribe' : 'Unsubscribe';
		const keywordLower = keyword.toLowerCase();
		const linker = subOrUnsub === 'sub' ? 'to' : 'from';

		const emailBodyPlain = `To ${keywordLower}, go to the following link: ${verifyUrl}`;
		const emailBodyHtml = `<p style="margin-top: 20px;">To ${keywordLower}, <a href="${verifyUrl}" target="_blank">click here</a>.</p>`;
		const subject = `${keyword} ${linker} the newsletter`;

		await client.send(
			new SendEmailCommand({
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
			})
		);
	} catch (e: unknown) {
		throw new Error(
			`Failed to send email FROM (${senderEmail}) TO (${recipient}): ${(e as Error).message}`
		);
	}
}
