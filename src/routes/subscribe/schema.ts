import { z } from 'zod';

export const formSchema = z.object({
	email: z.string().email(),
	topics: z.string().array().nonempty()
});

export type FormSchema = typeof formSchema;
