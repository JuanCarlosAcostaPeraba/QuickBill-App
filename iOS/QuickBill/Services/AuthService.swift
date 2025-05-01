//
//  AuthService.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//

import Foundation
import FirebaseAuth

class AuthService {
    private var handle: AuthStateDidChangeListenerHandle?
    
    func observeAuthStateChange(_ onChange: @escaping (Bool) -> Void) {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            onChange(user != nil)
        }
    }
    
    func removeAuthStateListener() {
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
        }
    }
    
    func isUserSignedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
