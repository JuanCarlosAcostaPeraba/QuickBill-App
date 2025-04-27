//
//  QuickBillApp.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 22/4/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
  // add published property
  @Published var isSignedIn: Bool = false

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    // Listen for auth state changes
    Auth.auth().addStateDidChangeListener { _, user in
        DispatchQueue.main.async {
            self.isSignedIn = (user != nil)
        }
    }
    return true
  }
}

@main
struct QuickBillApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            if delegate.isSignedIn {
                HomeView()
            } else {
                StartView()
            }
        }
    }
}
