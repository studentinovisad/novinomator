import { string, z } from 'zod';

export const formSchema = z.object({
	email: z.string().email(),
	topics: z.array(string())
});

export type FormSchema = typeof formSchema;
