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
    @AppStorage("appLanguage") private var appLanguage: String = AppLanguage.english.rawValue
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if auth.isSignedIn {
                MainTabView()
            } else {
                StartView()
            }
        }
        .environmentObject(auth)
        .environment(\.locale, Locale(identifier: appLanguage))
    }
}
