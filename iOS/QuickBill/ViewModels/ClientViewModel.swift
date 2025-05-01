//
//  ClientViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ClientViewModel: ObservableObject {
    @Published var companyName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var address: String = ""
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var postcode: String = ""
    @Published var clientName: String = ""
    @Published var isEditing: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let db = Firestore.firestore()
    private let clientId: String
    
    init(client: Client) {
        self.clientId = client.id
        loadClient(client: client)
    }
    
    private func loadClient(client: Client) {
        // Initialize from passed model
        self.companyName = client.companyName
        self.email       = client.email
        self.phone       = client.phone
        self.address     = client.address
        self.city        = client.city
        self.country     = client.country
        self.postcode    = client.postcode
        self.clientName  = client.clientName
    }
    
    func saveChanges() {
        Task {
            do {
                // 1) Find this user's businessRef
                guard let currentUid = Auth.auth().currentUser?.uid else { throw NSError() }
                let empSnap = try await db.collectionGroup("employees")
                    .whereField("userId", isEqualTo: currentUid)
                    .getDocuments()
                guard let empDoc = empSnap.documents.first,
                      let businessRef = empDoc.reference.parent.parent else {
                    throw NSError(domain: "ClientView", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "Business not found"])
                }
                // 2) Update the client document
                try await businessRef
                    .collection("clients")
                    .document(clientId)
                    .updateData([
                        "companyName": companyName,
                        "email": email,
                        "phone": phone,
                        "address": address,
                        "city": city,
                        "country": country,
                        "postcode": postcode,
                        "clientName": clientName
                    ])
                
                alertMessage = "Client updated successfully."
                showAlert = true
                isEditing = false
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}