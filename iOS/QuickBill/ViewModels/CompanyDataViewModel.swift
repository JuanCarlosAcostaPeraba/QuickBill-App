//
//  CompanyDataViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class CompanyDataViewModel: ObservableObject {
    @Published var companyName: String = ""
    @Published var tagline: String = ""
    @Published var taxId: String = ""
    @Published var companyEmail: String = ""
    @Published var companyPhone: String = ""
    @Published var address: String = ""
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var postcode: String = ""
    @Published var isEditing: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    private let db = Firestore.firestore()
    private var userId: String { Auth.auth().currentUser?.uid ?? "" }

    init() {
        loadCompanyData()
    }

    /// Finds the business document via the employee record, then loads its data
    func loadCompanyData() {
        Task {
            do {
                let empSnap = try await db.collectionGroup("employees")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                guard let empDoc = empSnap.documents.first,
                      let businessRef = empDoc.reference.parent.parent else {
                    alertMessage = "Business record not found"
                    showAlert = true
                    return
                }
                let bizSnap = try await businessRef.getDocument()
                let data = bizSnap.data() ?? [:]
                companyName   = data["name"] as? String ?? ""
                tagline       = data["tagline"] as? String ?? ""
                taxId         = data["taxId"] as? String ?? ""
                companyEmail  = data["email"] as? String ?? ""
                companyPhone  = data["phone"] as? String ?? ""
                address       = data["address"] as? String ?? ""
                city          = data["city"] as? String ?? ""
                country       = data["country"] as? String ?? ""
                postcode      = data["postcode"] as? String ?? ""
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    /// Saves edits back to Firestore
    func saveChanges() {
        Task {
            do {
                let empSnap = try await db.collectionGroup("employees")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                guard let empDoc = empSnap.documents.first,
                      let businessRef = empDoc.reference.parent.parent else {
                    alertMessage = "Business record not found"
                    showAlert = true
                    return
                }
                try await businessRef.updateData([
                    "name": companyName,
                    "tagline": tagline,
                    "taxId": taxId,
                    "email": companyEmail,
                    "phone": companyPhone,
                    "address": address,
                    "city": city,
                    "country": country,
                    "postcode": postcode
                ])
                alertMessage = "Company data updated"
                showAlert = true
                isEditing = false
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}
