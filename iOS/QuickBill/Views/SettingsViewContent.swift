//
//  SettingsView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//

import SwiftUI
import FirebaseAuth

struct SettingsViewContent: View {
    
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Settings options
                VStack(alignment: .leading, spacing: 15) {
                    SettingsRowComponent(title: "Profile", destination: EmptyView()/*ProfileView()*/)
                    SettingsRowComponent(title: "Company Data", destination: EmptyView()/*CompanyDataView()*/)
                    SettingsRowComponent(title: "Employees", destination: EmptyView()/*EmployeesView()*/)
                }
                .font(.headline)
                .padding()

                Spacer()

                // Sign out
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        auth.isSignedIn = false
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }) {
                    Text("Sign out")
                        .foregroundColor(.red)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)

            }
            .navigationBarHidden(true)
        }
    }
}
