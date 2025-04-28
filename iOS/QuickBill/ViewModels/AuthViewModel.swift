//
//  AuthViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 28/4/25.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
  @Published var isSignedIn: Bool = Auth.auth().currentUser != nil
  private var handle: AuthStateDidChangeListenerHandle?

  init() {
    handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      DispatchQueue.main.async {
        self?.isSignedIn = (user != nil)
      }
    }
  }

  deinit {
    if let h = handle {
      Auth.auth().removeStateDidChangeListener(h)
    }
  }
}
