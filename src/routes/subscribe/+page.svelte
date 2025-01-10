<script lang="ts">
	import * as Card from '$lib/components/ui/card/index.js';
	import * as Form from '$lib/components/ui/form';
	import * as Select from '$lib/components/ui/select';
	import { Input } from '$lib/components/ui/input/index.js';
	import { superForm } from 'sveltekit-superforms';
	import { zodClient } from 'sveltekit-superforms/adapters';
	import { toast } from 'svelte-sonner';
	import { formSchema } from './schema';
	import { page } from '$app/state';
	import Logo from '$lib/components/custom/logo/logo.svelte';

	let { data, form: actionData } = $props();

	const form = superForm(data.form, {
		validators: zodClient(formSchema),
		onUpdated: ({ form: f }) => {
			if (actionData?.message === undefined) return;
			const msg = actionData.message;
			if (f.valid && page.status === 200) {
				toast.success(msg);
			} else {
				toast.error(msg);
			}
		}
	});

	const { form: formData, enhance } = form;

	const topics = $derived(data.topics);
	const selectedTopics = $derived(
		$formData.topics.length
			? topics.filter((topic) => $formData.topics.includes(topic)).join(', ')
			: 'Select the topics to subscribe to'
	);
</script>

<div class="flex h-screen w-full items-center justify-center px-4">
	<form method="POST" class="flex w-full items-center justify-center px-4 pt-4" use:enhance>
		<Card.Root class="mx-auto w-full max-w-sm portrait:border-0">
			<Card.Header class="flex-col items-center">
				<Logo class="size-20 sm:pb-3" />
				<Card.Title class="text-2xl">Subscribe</Card.Title>
				<Card.Description class="hidden text-center sm:block">
					Enter your email and pick topics to subscribe to the newsletter.
				</Card.Description>
			</Card.Header>
			<Card.Content class="grid gap-4">
				<Form.Field {form} name="email">
					<Form.Control>
						{#snippet children({ props })}
							<Form.Label>Email</Form.Label>
							<Input {...props} bind:value={$formData.email} />
						{/snippet}
					</Form.Control>
					<Form.FieldErrors />
				</Form.Field>
				<Form.Field {form} name="topics">
					<Form.Control>
						{#snippet children({ props })}
							<Form.Label>Topics</Form.Label>
							<Select.Root type="multiple" bind:value={$formData.topics} name={props.name}>
								<Select.Trigger class={$formData.topics.length ? 'capitalize' : ''}>
									{selectedTopics}
								</Select.Trigger>
								<Select.Content>
									{#each topics as topic (topic)}
										<Select.Item class="capitalize" value={topic}>{topic}</Select.Item>
									{/each}
								</Select.Content>
							</Select.Root>
						{/snippet}
					</Form.Control>
					<Form.FieldErrors />
				</Form.Field>
				<Form.Button>Subscribe</Form.Button>
			</Card.Content>
			<Card.Footer>
				<p class="text-muted-foreground w-full px-2 text-center text-sm">
					This software is licensed under the <a
						href="https://raw.githubusercontent.com/studentinovisad/novinomator/refs/heads/main/LICENSE"
						class="hover:text-primary underline underline-offset-4"
					>
						MIT
					</a> License.
				</p>
			</Card.Footer>
		</Card.Root>
	</form>
</div>
