//
//  ProfileViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var isEditing: Bool = false
    @Published var showAlert = false
    @Published var alertMessage = ""

    private let db = Firestore.firestore()
    private var userId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    init() {
        loadProfile()
    }

    func loadProfile() {
        Task {
            do {
                let empQuery = try await db.collectionGroup("employees")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                guard let empDoc = empQuery.documents.first else { return }
                let data = empDoc.data()
                fullName = data["name"] as? String ?? ""
                email = data["email"] as? String ?? ""
                phone = data["phone"] as? String ?? ""
            } catch {
                // Fallback to auth email
                email = Auth.auth().currentUser?.email ?? ""
            }
        }
    }

    func saveChanges() {
        Task {
            do {
                // Update Firestore employee record
                let empQuery = try await db.collectionGroup("employees")
                    .whereField("userId", isEqualTo: userId)
                    .getDocuments()
                if let empDoc = empQuery.documents.first {
                    try await empDoc.reference.updateData([
                        "name": fullName,
                        "phone": phone
                    ])
                }
                showAlert = true
                alertMessage = "Profile updated"
                isEditing = false
            } catch {
                showAlert = true
                alertMessage = error.localizedDescription
            }
        }
    }
    
    /// Sends a password reset email to the current user
    func resetPassword() {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                alertMessage = "A password reset link has been sent to \(email)."
                showAlert = true
            } catch {
                alertMessage = "Error sending reset: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}
