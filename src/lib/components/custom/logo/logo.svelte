<script lang="ts">
	import { cn } from '$lib/utils.js';
	import LogoLight from '$lib/assets/images/light.svg';
	import LogoDark from '$lib/assets/images/dark.svg';

	let { class: className }: { class: string } = $props();
</script>

<img class={cn('hidden dark:block', className)} src={LogoLight} alt="Logo light" />
<img class={cn('block dark:hidden', className)} src={LogoDark} alt="Logo dark" />
