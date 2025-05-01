//
//  SettingsViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import Foundation
import FirebaseAuth

@MainActor
class SettingsViewModel: ObservableObject {
    func signOut(auth: AuthViewModel) {
        do {
            try Auth.auth().signOut()
            auth.isSignedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
