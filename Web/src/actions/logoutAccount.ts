import { auth } from '@/firebase/config'
import { defineAction } from 'astro:actions'

export const logoutAccount = defineAction({
	handler: async () => {
		await auth.signOut()
	},
})
