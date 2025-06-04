import { defineMiddleware } from 'astro:middleware'
import { auth } from '@/firebase/firebase'

export const onRequest = defineMiddleware((context, next) => {
	const currentUser = auth.currentUser
	const { pathname } = context.url

	if (
		!currentUser &&
		pathname !== '/login' &&
		context.request.method === 'GET'
	) {
		return context.redirect('/login')
	}

	if (currentUser) {
		context.locals.userEmail = currentUser.email
	}

	if (currentUser && pathname === '/login') {
		return context.redirect('/')
	}

	return next()
})
