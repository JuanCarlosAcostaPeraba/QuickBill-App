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
    @AppStorage("appLanguage") private var appLanguage: String = AppLanguage.english.rawValue   // ← nuevo
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Profile", destination: ProfileView())
                    NavigationLink("Company Data", destination: CompanyDataView())
                    NavigationLink("Employees",    destination: EmployeesView())
                }
                
                Section(header: Text("Language")) {
                    Picker("Language", selection: $appLanguage) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.nativeName).tag(lang.rawValue)
                        }
                    }
                    .pickerStyle(.menu)          // dropdown‑style picker
                    .labelsHidden()              // hide default label to look like a select
                    .frame(maxWidth: .infinity, alignment: .leading)
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
