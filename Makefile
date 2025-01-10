install:
	pnpm install --frozen-lockfile
	sed -i -E 's|npm:@sveltejs/kit@[^/"]+|@sveltejs/kit|g' ./node_modules/@hearchco/sveltekit-adapter-aws/handler/index.js