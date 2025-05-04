//
//  AddInvoiceViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 2/5/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AddInvoiceViewModel: ObservableObject {
    @Published var issuedAt: Date = Date()
    @Published var dueDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @Published var selectedClientId: String = ""
    @Published var lineItems: [InvoiceLineItem] = []
    @Published var clients: [Client] = []
    @Published var products: [Product] = []
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let db = Firestore.firestore()
    private var currentUserId: String { Auth.auth().currentUser?.uid ?? "" }
    
    /// Load all clients for the current business
    func fetchClients() {
        db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
            .getDocuments { empSnap, _ in
                guard let empDoc = empSnap?.documents.first,
                      let businessRef = empDoc.reference.parent.parent else { return }
                businessRef.collection("clients").getDocuments { snap, _ in
                    let items = snap?.documents.compactMap { doc -> Client? in
                        let data = doc.data()
                        guard
                            let companyName = data["companyName"] as? String,
                            let clientName = data["clientName"] as? String,
                            let email = data["email"] as? String,
                            let phone = data["phone"] as? String,
                            let address = data["address"] as? String,
                            let city = data["city"] as? String,
                            let country = data["country"] as? String,
                            let postcode = data["postcode"] as? String
                        else { return nil }
                        return Client(
                            id: doc.documentID,
                            companyName: companyName,
                            clientName: clientName,
                            email: email,
                            phone: phone,
                            address: address,
                            city: city,
                            country: country,
                            postcode: postcode
                        )
                    } ?? []
                    DispatchQueue.main.async {
                        self.clients = items
                        // Auto-select the first client if none selected yet
                        if self.selectedClientId.isEmpty, let first = items.first {
                            self.selectedClientId = first.id
                        }
                    }
                }
            }
    }
    
    /// Resets the form fields to their initial state for creating a new invoice
    func resetForm() {
        // Reset dates
        issuedAt = Date()
        dueDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        // Reset selected client to first if available
        if let firstClient = clients.first {
            selectedClientId = firstClient.id
        } else {
            selectedClientId = ""
        }
        // Clear and re-add a single blank line item
        lineItems = []
        addLineItem()
        // Clear any alert messages
        alertMessage = ""
        showAlert = false
    }
    
    /// Load all products for the current business
    func fetchProducts() {
        db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
            .getDocuments { empSnap, _ in
                guard let empDoc = empSnap?.documents.first,
                      let businessRef = empDoc.reference.parent.parent else { return }
                businessRef.collection("products").getDocuments { snap, _ in
                    let items = snap?.documents.compactMap { doc -> Product? in
                        let data = doc.data()
                        guard
                            let desc = data["description"] as? String,
                            let price = data["unitPrice"] as? Double
                        else { return nil }
                        return Product(id: doc.documentID, description: desc, unitPrice: price)
                    } ?? []
                    DispatchQueue.main.async {
                        self.products = items
                        // Auto-select the first product for any empty line items
                        if let firstProduct = items.first {
                            for idx in self.lineItems.indices {
                                if self.lineItems[idx].productId.isEmpty {
                                    self.lineItems[idx].productId = firstProduct.id
                                }
                            }
                        }
                    }
                }
            }
    }
    
    /// Add a new blank line item
    func addLineItem() {
        lineItems.append(InvoiceLineItem())
    }
    
    /// Save the invoice to Firestore under the business
    func saveInvoice(completion: @escaping (Result<Void, Error>) -> Void) {
        
        // 1) Validate inputs
        guard !selectedClientId.isEmpty, !lineItems.isEmpty else {
            alertMessage = "Select a client and add at least one product."
            showAlert = true
            completion(.failure(NSError(domain: "", code: -1)))
            return
        }
        
        // 2) Build the productsStack array
        let stackData: [[String: Any]] = lineItems.compactMap { item in
            guard let qty = Int(item.quantityText),
                  let amount = Double(item.amountText),
                  let tax = Double(item.taxRateText) else {
                return nil
            }
            return [
                "productId": item.productId,
                "supplyDate": Timestamp(date: issuedAt),
                "quantity": qty,
                "amount": amount,
                "taxRate": tax,
                "taxNet": amount * (tax / 100)
            ]
        }
        
        // 3) Compute totals
        let subtotal = stackData.reduce(0) { $0 + ($1["amount"] as? Double ?? 0) }
        let taxTotal = stackData.reduce(0) { $0 + ($1["taxNet"] as? Double ?? 0) }
        let totalAmount = subtotal + taxTotal
        
        // 4) Prepare base invoice data
        var invoiceData: [String: Any] = [
            "issuedAt": Timestamp(date: issuedAt),
            "dueDate": Timestamp(date: dueDate),
            "status": "Pending",
            "subtotal": subtotal,
            "taxTotal": taxTotal,
            "discounts": 0,
            "totalAmount": totalAmount,
            "currency": "€",
            "clientId": selectedClientId,
            "employeeId": currentUserId
        ]
        invoiceData["productsStack"] = stackData
        
        // 5) Lookup the business reference
        db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
            .getDocuments {
                empSnap,
                empErr in
                if let empErr = empErr {
                    completion(.failure(empErr)); return
                }
                guard let empDoc = empSnap?.documents.first,
                      let businessRef = empDoc.reference.parent.parent else {
                    completion(.failure(NSError(domain: "", code: -1))); return
                }
                
                // 6) Fetch subscriptionPlan to compute deleteAfter
                businessRef.getDocument {
                    bizSnap,
                    bizErr in
                    if let bizErr = bizErr {
                        completion(.failure(bizErr)); return
                    }
                    let plan = bizSnap?.data()?["subscriptionPlan"] as? String ?? "free"
                    if plan == "free" {
                        let deleteDate = Calendar.current.date(
                            byAdding: .month, value: 1, to: self.issuedAt
                        ) ?? self.issuedAt
                        invoiceData["deleteAfter"] = Timestamp(date: deleteDate)
                    }
                    
                    // 7) Write the invoice document
                    businessRef.collection("invoices").addDocument(data: invoiceData) { err in
                        if let err = err {
                            completion(.failure(err))
                        } else {
                            // 8) Write each line item to subcollection
                            businessRef.collection("invoices")
                                .whereField(
                                    "issuedAt",
                                    isEqualTo: Timestamp(date: self.issuedAt)
                                )
                                .whereField(
                                    "employeeId",
                                    isEqualTo: self.currentUserId
                                )
                                .getDocuments { invSnap, invErr in
                                    guard let invId = invSnap?.documents.first?.documentID, invErr == nil else {
                                        completion(.failure(invErr ?? NSError()))
                                        return
                                    }
                                    let invRef = businessRef.collection("invoices").document(invId)
                                    for entry in stackData {
                                        invRef.collection("productsStack").addDocument(data: entry)
                                    }
                                    completion(.success(()))
                                    
                                }
                        }
                    }
                }
            }
    }
}
