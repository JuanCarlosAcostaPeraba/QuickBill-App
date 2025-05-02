//
//  InvoiceListViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class InvoiceListViewModel: ObservableObject {
    /// Formatter for issuedAt date to support text search
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()
    
    @Published var invoices: [Invoice] = []
    @Published var selectedStatus: InvoiceStatus = .all
    @Published var searchText: String = ""
    @Published var showSearch: Bool = false
    
    var filteredInvoices: [Invoice] {
        invoices.filter { inv in
            (selectedStatus == .all || inv.status == selectedStatus) &&
            (searchText.isEmpty ||
             inv.companyName.lowercased().contains(searchText.lowercased()) ||
             dateFormatter.string(from: inv.issuedAt).contains(searchText) ||
             String(format: "%.2f", inv.totalAmount).contains(searchText)
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
                let fetched: [Invoice] = invSnap?.documents.compactMap { (doc) -> Invoice? in
                    let data = doc.data()
                    guard
                        let companyName = data["companyName"] as? String,
                        let issuedTs = data["issuedAt"] as? Timestamp,
                        let dueTs = data["dueDate"] as? Timestamp,
                        let subtotal = data["subtotal"] as? Double,
                        let taxTotal = data["taxTotal"] as? Double,
                        let discounts = data["discounts"] as? Double,
                        let totalAmount = data["totalAmount"] as? Double,
                        let currency = data["currency"] as? String,
                        let clientId = data["clientId"] as? String,
                        let employeeId = data["employeeId"] as? String,
                        let statusRaw = data["status"] as? String,
                        let status = InvoiceStatus(rawValue: statusRaw)
                    else {
                        return nil
                    }
                    // Convert timestamps to Date
                    let issuedAt = issuedTs.dateValue()
                    let dueDate = dueTs.dateValue()
                    // Optional fields
                    let pdfURL: URL? = {
                        if let urlString = data["pdfURL"] as? String {
                            return URL(string: urlString)
                        }
                        return nil
                    }()
                    let deleteAfter: Date? = (data["deleteAfter"] as? Timestamp)?.dateValue()
                    // For now, leave productsStack empty; can fetch subcollection later
                    let productsStack: [ProductStack] = []
                    return Invoice(
                        id: doc.documentID,
                        companyName: companyName,
                        issuedAt: issuedAt,
                        dueDate: dueDate,
                        amount: totalAmount,
                        subtotal: subtotal,
                        taxTotal: taxTotal,
                        discounts: discounts,
                        totalAmount: totalAmount,
                        currency: currency,
                        clientId: clientId,
                        employeeId: employeeId,
                        pdfURL: pdfURL,
                        deleteAfter: deleteAfter,
                        productsStack: productsStack,
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
