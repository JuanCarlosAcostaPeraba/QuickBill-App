//
//  AuthViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 28/4/25.
//

import Foundation

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    private let authService: AuthService
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        self.isSignedIn = authService.isUserSignedIn()
        authService.observeAuthStateChange { [weak self] isSignedIn in
            DispatchQueue.main.async {
                self?.isSignedIn = isSignedIn
            }
        }
    }
    
    deinit {
        authService.removeAuthStateListener()
    }
}
