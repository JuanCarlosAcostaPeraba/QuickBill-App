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

/*
 const loginSection = document.getElementById('login-section')
 const dashboardHeader = document.getElementById('dashboard-section')
 const dashboardMain = document.getElementById('dashboard-main')
 const signOutBtn = document.getElementById('sign-out-btn')
 const errorBox = document.getElementById('login-error')
 const loginForm = document.getElementById('login-form')

 // ---------- Login form ----------
 loginForm.addEventListener('submit', async (e) => {
 e.preventDefault()
 errorBox.textContent = ''

 const email = loginForm.email.value.trim()
 const password = loginForm.password.value.trim()

 if (!email || !password) {
 errorBox.textContent = 'Email and password are required.'
 return
 }
 try {
 await signInWithEmailAndPassword(auth, email, password)
 // UI switch occurs in onAuthStateChanged
 } catch (err) {
 errorBox.textContent = err.message ?? 'Authentication failed.'
 }
 })

 // ---------- Sign‑out ----------
 signOutBtn.addEventListener('click', async () => {
 try {
 await signOut(auth)
 } catch {}
 })

 // ---------- Auth listener ----------
 onAuthStateChanged(auth, async (user) => {
 if (user) {
 // show dashboard
 loginSection.classList.add('hidden')
 dashboardHeader.classList.remove('hidden')
 dashboardMain.classList.remove('hidden')

 const grid = document.getElementById('invoiceGrid')
 grid.setAttribute('loading', '')

 try {
 // 1️⃣ Fetch all clients once and build a lookup map
 const clientSnap = await getDocs(collectionGroup(db, 'clients'))
 const clientMap = {}
 clientSnap.forEach((c) => {
 const data = c.data()
 // prefer companyName, fallback to clientName, else ID
 clientMap[c.id] = data.companyName || data.clientName || c.id
 })

 // 2️⃣ Fetch invoices
 const invSnap = await getDocs(collectionGroup(db, 'invoices'))
 if (invSnap.empty) {
 grid.setData([])
 return
 }

 const rows = []
 invSnap.forEach((doc) => {
 const d = doc.data()
 rows.push({
 client: clientMap[d.clientId] ?? d.clientId ?? '-',
 issued:
 d.issuedAt instanceof Timestamp ?
 d.issuedAt.toDate().toISOString().slice(0, 10)
 : '',
 total: (d.totalAmount ?? 0).toFixed(2),
 status: (d.status ?? '-').replace(/^./, (c) => c.toUpperCase()),
 })
 })

 grid.setData(rows)

 // 3️⃣ Build monthly sums (paid & pending)
 const monthly = {}; // { 'YYYY-MM': { paid, pending } }
 rows.forEach((r) => {
 const [y, m] = r.issued.split('-');
 if (!y) return;
 const key = ${y}-${m};
 if (!monthly[key]) monthly[key] = { paid: 0, pending: 0 };
 if (r.status.toLowerCase() === 'paid') {
 monthly[key].paid += parseFloat(r.total);
 } else if (r.status.toLowerCase() === 'pending') {
 monthly[key].pending += parseFloat(r.total);
 }
 });

 // 4️⃣ Convert to two adjacent bars per month
 const ms12h = 12  60  60 * 1000;
 const paidData = [];
 const pendingData = [];

 Object.keys(monthly)
 .sort()
 .forEach((key) => {
 const [yyyy, mm] = key.split('-');
 const base = new Date(${yyyy}-${mm}-01T00:00:00Z).getTime(); // UTC
 // Lightweight accepts numeric seconds since epoch
 const baseSec = Math.floor(base / 1000);

 // Pending bar (left)
 pendingData.push({
 time: baseSec,
 value: monthly[key].pending,
 color: '#facc15',
 });
 // Paid bar (right, +12h)
 paidData.push({
 time: Math.floor((base + ms12h) / 1000),
 value: monthly[key].paid,
 color: '#16a34a',
 });
 });

 // 5️⃣ Render / update chart
 const container = document.getElementById('moneyChart');
 if (!container.__chart__) {
 const { createChart, HistogramSeries } = await import(
 'https://cdn.jsdelivr.net/npm/lightweight-charts@5.0.7/+esm'
 );
 const chart = createChart(container, {
 layout: {
 textColor: '#374151',
 background: { type: 'solid', color: 'white' },
 },
 height: 250,
 timeScale: {
 tickMarkFormatter: (time) => {
 // time is seconds since epoch (numeric)
 const date = new Date(time * 1000);
 return date.toLocaleString('default', { month: 'short' }); // e.g., Jan, Feb...
 },
 },
 });
 const pendSeries = chart.addSeries(HistogramSeries, { color: '#facc15' });
 const paidSeries = chart.addSeries(HistogramSeries, { color: '#16a34a' });
 pendSeries.setData(pendingData);
 paidSeries.setData(paidData);
 chart.timeScale().fitContent();
 container.__chart__ = { chart, paidSeries, pendSeries };
 } else {
 const { paidSeries, pendSeries, chart } = container.__chart__;
 pendSeries.setData(pendingData);
 paidSeries.setData(paidData);
 chart.timeScale().fitContent();
 }

 } catch (err) {
 console.error('Firestore fetch error', err)
 grid.setData([])
 } finally {
 grid.removeAttribute('loading')
 }
 } else {
 // show login
 loginSection.classList.remove('hidden')
 dashboardHeader.classList.add('hidden')
 dashboardMain.classList.add('hidden')
 }
 })
*/
