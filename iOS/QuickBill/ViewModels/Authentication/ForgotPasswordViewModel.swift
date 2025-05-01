//
//  ForgotPasswordViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import Foundation
import FirebaseAuth

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    /// Sends a password reset email and updates alert state
    func resetPassword() async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            alertMessage = "A password reset link has been sent to \(email)."
        } catch {
            alertMessage = error.localizedDescription
        }
        showAlert = true
    }
}
