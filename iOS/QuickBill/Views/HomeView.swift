//
//  HomeView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 25/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum InvoiceStatus: String, CaseIterable {
    case all = "All"
    case paid = "Paid"
    case pending = "Pending"
    case overdue = "Overdue"
    
    var iconName: String {
        switch self {
        case .all: return "tray"
        case .paid: return "dollarsign.circle"
        case .pending: return "calendar"
        case .overdue: return "bell"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color.blue
        case .paid: return Color.green
        case .pending: return Color.blue
        case .overdue: return Color.red
        }
    }
}

struct Invoice: Identifiable {
    let id: String
    let companyName: String
    let period: String
    let amount: Double
    let currency: String
    let status: InvoiceStatus
}

class InvoiceListViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var selectedStatus: InvoiceStatus = .all
    @Published var searchText: String = ""
    @Published var showSearch: Bool = false
    
    var filteredInvoices: [Invoice] {
        invoices.filter { inv in
            (selectedStatus == .all || inv.status == selectedStatus) &&
            (searchText.isEmpty ||
                inv.companyName.lowercased().contains(searchText.lowercased()) ||
                inv.period.contains(searchText) ||
                String(format: "%.2f", inv.amount).contains(searchText)
            )
        }
    }
    
    func fetchInvoices() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // 1. Find the employee document for this user
        let empQuery = Firestore.firestore().collectionGroup("employees")
            .whereField("userId", isEqualTo: uid)
        empQuery.getDocuments { empSnap, empErr in
            if let empErr = empErr {
                print("Error fetching employee record: \(empErr)")
                return
            }
            guard let empDoc = empSnap?.documents.first,
                  let businessRef = empDoc.reference.parent.parent else {
                print("No business found for user \(uid)")
                return
            }
            // 2. Fetch invoices under that business
            businessRef.collection("invoices").getDocuments { invSnap, invErr in
                if let invErr = invErr {
                    print("Error fetching invoices: \(invErr)")
                    return
                }
                let fetched: [Invoice] = invSnap?.documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let companyName = data["clientName"] as? String ?? data["companyName"] as? String,
                        let timestamp = data["issuedAt"] as? Timestamp,
                        let amount = data["totalAmount"] as? Double,
                        let currency = data["currency"] as? String,
                        let statusRaw = data["status"] as? String,
                        let status = InvoiceStatus(rawValue: statusRaw)
                    else {
                        return nil
                    }
                    // Format period as month/year
                    let date = timestamp.dateValue()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/yyyy"
                    let period = formatter.string(from: date)
                    return Invoice(
                        id: doc.documentID,
                        companyName: companyName,
                        period: period,
                        amount: amount,
                        currency: currency,
                        status: status
                    )
                } ?? []
                DispatchQueue.main.async {
                    self.invoices = fetched
                }
            }
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = InvoiceListViewModel()
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        VStack(spacing: 0) {
            // Toggle search button
            HStack {
                Spacer()
                Button(action: {
                    viewModel.showSearch.toggle()
                }) {
                    Image(systemName: viewModel.showSearch ? "xmark" : "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            // Search bar
            if viewModel.showSearch {
                TextField("Search invoices...", text: $viewModel.searchText)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            
            // Filter bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(InvoiceStatus.allCases, id: \.self) { status in
                        Button {
                            withAnimation { viewModel.selectedStatus = status }
                        } label: {
                            HStack {
                                Image(systemName: status.iconName)
                                Text(status.rawValue)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .foregroundColor(viewModel.selectedStatus == status ? .white : .gray)
                            .background(viewModel.selectedStatus == status ? status.color : Color.gray.opacity(0.2))
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            // Invoice grid
            if viewModel.filteredInvoices.isEmpty {
                Text("Empty")
                    .font(.title)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.filteredInvoices) { invoice in
                            InvoiceCardView(invoice: invoice)
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
            // Bottom navigation bar
            BarNavComponent(selectedTab: $selectedTab)
        }
        .onAppear {
            viewModel.fetchInvoices()
        }
    }
}

struct InvoiceCardView: View {
    let invoice: Invoice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(invoice.companyName)
                .font(.headline)
            Text(invoice.period)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(String(format: "%.2f", invoice.amount))\(invoice.currency)")
                .font(.title2)
                .fontWeight(.bold)
            Text(invoice.status.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(4)
                .background(invoice.status.color)
                .cornerRadius(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
