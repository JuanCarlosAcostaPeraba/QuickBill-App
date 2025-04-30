//
//  EmployeeViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// ViewModel for editing an employee's data
@MainActor
class EmployeeViewModel: ObservableObject {
    @Published var name: String
    @Published var email: String
    @Published var phone: String
    @Published var isAdmin: Bool
    @Published var isEditing: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    private let db = Firestore.firestore()
    private let employeeId: String

    init(employee: Employee) {
        self.name = employee.name
        self.email = employee.email
        self.phone = employee.phone
        self.isAdmin = (employee.role.lowercased() == "admin")
        self.employeeId = employee.id
    }

    /// Saves edits back to Firestore under the current user's business
    func saveChanges() {
        Task {
            do {
                // Find the business reference via current user's employee doc
                let currentUid = Auth.auth().currentUser?.uid ?? ""
                let empQuery = try await db.collectionGroup("employees")
                    .whereField("userId", isEqualTo: currentUid)
                    .getDocuments()
                guard let empDoc = empQuery.documents.first,
                      let businessRef = empDoc.reference.parent.parent else {
                    throw NSError(domain: "EmployeeView", code: 0, userInfo: [NSLocalizedDescriptionKey: "Business not found"])
                }

                // Sync role string from toggle
                let roleString = isAdmin ? "admin" : "employee"

                // Update the specific employee document
                try await businessRef
                    .collection("employees")
                    .document(employeeId)
                    .updateData([
                        "name": name,
                        "phone": phone,
                        "role": roleString
                    ])

                alertMessage = "Employee updated successfully."
                showAlert = true
                isEditing = false
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}
