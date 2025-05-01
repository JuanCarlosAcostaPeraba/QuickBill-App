//
//  ClientsViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import FirebaseAuth
import FirebaseFirestore

@MainActor
class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    private let db = Firestore.firestore()
    private var currentUserId: String { Auth.auth().currentUser?.uid ?? "" }
    
    func fetchClients() {
        // 1) Find the current user's business reference
        let empQuery = db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
        empQuery.getDocuments { empSnap, empErr in
            if let empErr = empErr {
                print("Error finding current employee record: \(empErr)")
                return
            }
            guard let empDoc = empSnap?.documents.first,
                  let businessRef = empDoc.reference.parent.parent else {
                print("Business not found for user \(self.currentUserId)")
                return
            }
            // 2) Fetch all clients under that business
            businessRef.collection("clients").getDocuments { snap, err in
                if let err = err {
                    print("Error fetching clients: \(err)")
                    return
                }
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
                    else {
                        return nil
                    }
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
                }
            }
        }
    }
    /// Adds a new client under the current user's business
    func addClient(companyName: String, clientName: String, email: String, phone: String,
                   address: String, city: String, country: String, postcode: String) {
        let empQuery = db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
        empQuery.getDocuments { empSnap, empErr in
            if let empErr = empErr {
                print("Error finding business for addClient: \(empErr)")
                return
            }
            guard let empDoc = empSnap?.documents.first,
                  let businessRef = empDoc.reference.parent.parent else {
                print("Business not found for user \(self.currentUserId)")
                return
            }
            let newRef = businessRef.collection("clients").document()
            let data: [String: Any] = [
                "companyName": companyName,
                "clientName": clientName,
                "email": email,
                "phone": phone,
                "address": address,
                "city": city,
                "country": country,
                "postcode": postcode,
                "createdAt": Timestamp()
            ]
            newRef.setData(data) { err in
                if let err = err {
                    print("Error adding client: \(err)")
                } else {
                    DispatchQueue.main.async {
                        self.fetchClients()
                    }
                }
            }
        }
    }
}
