<script lang="ts">
	import { page } from '$app/state';
	import { toast } from 'svelte-sonner';
	import * as Card from '$lib/components/ui/card/index.js';
	import Logo from '$lib/components/custom/logo/logo.svelte';

	let { data } = $props();

	const msg = $derived.by(() => {
		const nonEmptyMsg = data.message ?? '';
		if (page.status === 200) {
			toast.success(nonEmptyMsg);
		} else {
			toast.error(nonEmptyMsg);
		}
		return nonEmptyMsg;
	});
</script>

<div class="flex h-screen w-full items-center justify-center px-4">
	<div class="flex w-full items-center justify-center px-4 pt-4">
		<Card.Root class="mx-auto w-full max-w-sm portrait:border-0">
			<Card.Header class="flex-col items-center">
				<Logo class="size-20 sm:pb-3" />
				<Card.Title class="text-2xl">Subscribe</Card.Title>
				<!-- <Card.Description class="hidden text-center sm:block">
					Enter your email and pick topics to subscribe to the newsletter.
				</Card.Description> -->
			</Card.Header>
			<Card.Content class="grid gap-4">
				<p class="text-center">{msg}</p>
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
	</div>
</div>
