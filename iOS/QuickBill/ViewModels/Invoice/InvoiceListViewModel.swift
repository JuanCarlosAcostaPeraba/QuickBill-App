//
//  InvoiceListViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

private struct ClientInfo {
    let id: String
    let name: String
}

class InvoiceListViewModel: ObservableObject {
    /// Formatter for issuedAt date to support text search
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()
    
    @Published var invoices: [Invoice] = []
    @Published var clientNameById: [String: String] = [:]
    @Published var selectedStatus: InvoiceStatus = .all
    @Published var searchText: String = ""
    @Published var showSearch: Bool = false
    
    /// Filtered invoices based on selected status and search text
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
    
    /// Fetches invoices from Firestore
    func fetchInvoices() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let firestore = Firestore.firestore()
        firestore.collectionGroup("employees")
            .whereField("userId", isEqualTo: uid)
            .getDocuments {
                empSnap,
                empErr in
                
                if let empErr = empErr {
                    print("Error fetching employee record: \(empErr)")
                    return
                }
                guard
                    let empDoc = empSnap?.documents.first,
                    let businessRef = empDoc.reference.parent.parent
                else {
                    print("No business found for user \(uid)")
                    return
                }
                
                // 2. Pre‑fetch all clients once and build a [clientId: name] dictionary
                businessRef.collection("clients").getDocuments {
                    clientSnap,
                    _ in
                    var nameDict: [String: String] = [:]
                    if let docs = clientSnap?.documents {
                        for doc in docs {
                            let d = doc.data()
                            // Usa companyName, o clientName si no existe companyName
                            let name = (d["companyName"] as? String) ??
                            (d["clientName"] as? String) ?? "—"
                            self.clientNameById[doc.documentID] = d["clientName"] as? String
                            nameDict[doc.documentID] = name
                        }
                    }
                    
                    businessRef.collection("invoices").getDocuments { invSnap, invErr in
                        if let invErr = invErr {
                            print("Error fetching invoices: \(invErr)")
                            return
                        }
                        
                        let fetched: [Invoice] = invSnap?.documents.compactMap { doc -> Invoice? in
                            let data = doc.data()
                            
                            guard
                                let issuedTs    = data["issuedAt"]   as? Timestamp,
                                let dueTs       = data["dueDate"]    as? Timestamp,
                                let subtotal    = data["subtotal"]   as? Double,
                                let taxTotal    = data["taxTotal"]   as? Double,
                                let discounts   = data["discounts"]  as? Double,
                                let totalAmount = data["totalAmount"]as? Double,
                                let currency    = data["currency"]   as? String,
                                let clientId    = data["clientId"]   as? String,
                                let employeeId  = data["employeeId"] as? String,
                                let statusRaw   = data["status"]     as? String,
                                let status      = InvoiceStatus(rawValue: statusRaw)
                            else { return nil }
                            
                            let companyName = nameDict[clientId] ?? "—"
                            
                            let pdfURL      = (data["pdfURL"] as? String).flatMap(URL.init(string:))
                            let deleteAfter = (data["deleteAfter"] as? Timestamp)?.dateValue()
                            
                            return Invoice(
                                id:            doc.documentID,
                                companyName:   companyName,
                                issuedAt:      issuedTs.dateValue(),
                                dueDate:       dueTs.dateValue(),
                                amount:       totalAmount,
                                subtotal:      subtotal,
                                taxTotal:      taxTotal,
                                discounts:     discounts,
                                totalAmount:   totalAmount,
                                currency:      currency,
                                clientId:      clientId,
                                employeeId:    employeeId,
                                pdfURL:        pdfURL,
                                deleteAfter:   deleteAfter,
                                productsStack: [],
                                status:        status
                            )
                        } ?? []
                        
                        DispatchQueue.main.async {
                            self.invoices = fetched
                        }
                    }
                }
            }
    }
    
    /// Return client name for a given client id
    func getClientName(for clientId: String) -> String {
        clientNameById[clientId] ?? "—"
    }
}
