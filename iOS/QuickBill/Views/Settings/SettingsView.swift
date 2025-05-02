//
//  SettingsView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: ProfileView()) {
                        Text("Profile")
                    }
                    NavigationLink(destination: CompanyDataView()) {
                        Text("Company Data")
                    }
                    NavigationLink(destination: EmployeesView()) {
                        Text("Employees")
                    }
                }
                Section {
                    Button(role: .destructive) {
                        viewModel.signOut(auth: auth)
                    } label: {
                        Text("Sign out")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}
