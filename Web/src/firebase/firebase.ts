import { initializeApp } from 'firebase/app'
import {
	getFirestore,
	collection,
	getDocs,
	query,
	where,
} from 'firebase/firestore'
import { getAuth } from 'firebase/auth'
import { firebaseConfig } from './config'

const firebaseApp = initializeApp(firebaseConfig)
const firestore = getFirestore(firebaseApp)
const auth = getAuth(firebaseApp)

async function getEmployeesBy(businessId?: string) {
	const employeesQuery = query(
		collection(firestore, 'businesses', businessId, 'employees')
	)
	const employeesSnapshot = await getDocs(employeesQuery)
	if (employeesSnapshot.empty) {
		console.log('No employees found for this business.')
		return []
	}
	const employees = employeesSnapshot.docs.map((doc) => ({
		id: doc.id,
		...doc.data(),
	}))
	return employees
}

async function getClientsBy(businessId: string) {
	const clientsQuery = query(
		collection(firestore, 'businesses', businessId, 'clients')
	)
	const clientsSnapshot = await getDocs(clientsQuery)
	if (clientsSnapshot.empty) {
		console.log('No clients found for this business.')
		return []
	}
	const clients = clientsSnapshot.docs.map((doc) => ({
		id: doc.id,
		...doc.data(),
	}))
	return clients
}

async function getProductsBy(businessId: string) {
	const productsQuery = query(
		collection(firestore, 'businesses', businessId, 'products')
	)
	const productsSnapshot = await getDocs(productsQuery)
	if (productsSnapshot.empty) {
		console.log('No products found for this business.')
		return []
	}
	const products = productsSnapshot.docs.map((doc) => ({
		id: doc.id,
		...doc.data(),
	}))
	return products
}

async function getInvoicesBy(businessId: string) {
	const invoicesQuery = query(
		collection(firestore, 'businesses', businessId, 'invoices')
	)
	const invoicesSnapshot = await getDocs(invoicesQuery)
	if (invoicesSnapshot.empty) {
		console.log('No invoices found for this business.')
		return []
	}
	const invoices = invoicesSnapshot.docs.map((doc) => ({
		id: doc.id,
		...doc.data(),
	}))
	return invoices
}

async function getAllDataForUser(userId: string) {
	const allData = {}

	// 1. get all businesses
	const businessesQuery = await query(collection(firestore, 'businesses'))
	const businessesSnapshot = await getDocs(businessesQuery)
	if (businessesSnapshot.empty) {
		console.log('No businesses found.')
		return []
	}

	// 2. filter all businesses where the user is in the employees collection
	const businesData = businessesSnapshot.docs.map(async (doc) => {
		const businessData = doc.data()
		const businesId = doc.id
		const employees = await getEmployeesBy(businesId)
		const isEmployee =
			employees.filter((employee) => employee.userId === userId) || null
		if (!isEmployee || isEmployee.length === 0) {
			return null
		}
		return {
			id: businesId,
			...businessData,
		}
	})
	const businesses = (await Promise.all(businesData)).filter((b) => b !== null)
	if (businesses.length === 0) {
		console.log('No businesses found for this user.')
		return []
	}
	const businessId = businesses[0].id
	allData.businesses = businesses

	// 3. get all invoices that are inside the business collection
	const invoices = getInvoicesBy(businessId)
	allData.invoices = await invoices

	// 4. get all clients that are inside the business collection
	const clients = getClientsBy(businessId)
	allData.clients = await clients

	// 5. get all products that are inside the business collection
	const products = getProductsBy(businessId)
	allData.products = await products

	// 6. get all employees that are inside the business collection
	const employees = getEmployeesBy(businessId)
	allData.employees = await employees

	return allData
}

export { firebaseApp, auth, firestore, getAllDataForUser }
export default firebaseApp
