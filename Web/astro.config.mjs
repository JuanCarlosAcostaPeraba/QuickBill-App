// @ts-check
import { defineConfig } from 'astro/config'

import tailwindcss from '@tailwindcss/vite'
import vercel from '@astrojs/vercel'

// https://astro.build/config
export default defineConfig({
	vite: {
		plugins: [tailwindcss()],
		build: {
			rollupOptions: {
				external: ['firebase-admin', 'firebase-admin/app', 'firebase-admin/auth']
			}
		}
	},
	output: 'server',
	adapter: vercel(),
})
