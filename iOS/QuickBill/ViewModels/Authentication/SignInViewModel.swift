//
//  SignInViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import Foundation
import FirebaseAuth

@MainActor
class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showPassword: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var didSignIn: Bool = false
    
    /// Attempts to sign in with Firebase Auth
    func signIn() async {
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            didSignIn = true
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
