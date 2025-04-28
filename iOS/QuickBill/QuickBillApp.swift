//
//  QuickBillApp.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 22/4/25.
//

import SwiftUI
import FirebaseCore

@main
struct QuickBillApp: App {
  @StateObject private var auth = AuthViewModel()

  init() {
    FirebaseApp.configure()
  }

  var body: some Scene {
    WindowGroup {
      if auth.isSignedIn {
        HomeView()
      } else {
        StartView()
      }
    }
  }
}
