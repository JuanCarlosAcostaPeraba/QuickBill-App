import { auth } from '@/firebase/firebase'
import { defineAction } from 'astro:actions'

export const logoutAccount = defineAction({
	handler: async () => {
		await auth.signOut()
	},
})
