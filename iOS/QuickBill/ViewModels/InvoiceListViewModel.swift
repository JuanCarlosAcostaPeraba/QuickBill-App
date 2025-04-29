//
//  InvoiceListViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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