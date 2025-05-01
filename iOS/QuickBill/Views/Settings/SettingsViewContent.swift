//
//  SettingsView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//

import SwiftUI

struct SettingsViewContent: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 15) {
                    SettingsRowComponent(title: "Profile", destination: ProfileView())
                    SettingsRowComponent(title: "Company Data", destination: CompanyDataView())
                    SettingsRowComponent(title: "Employees", destination: EmployeesView())
                }
                .font(.headline)
                .padding()
                
                Spacer()
                
                Button(action: {
                    viewModel.signOut(auth: auth)
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
