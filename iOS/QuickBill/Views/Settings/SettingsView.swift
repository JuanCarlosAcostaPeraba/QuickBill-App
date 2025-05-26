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
    @AppStorage("appLanguage") private var appLanguage: String = AppLanguage.english.rawValue
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Profile", destination: ProfileView())
                    NavigationLink("Company Data", destination: CompanyDataView())
                    NavigationLink("Employees",    destination: EmployeesView())
                }
                
                Section(header: Text("Language")) {
                    NavigationLink {
                        List {
                            ForEach(AppLanguage.allCases) { lang in
                                Button {
                                    appLanguage = lang.rawValue
                                } label: {
                                    HStack {
                                        Text(lang.nativeName)
                                        if appLanguage == lang.rawValue {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle("Language")
                    } label: {
                        HStack {
                            Text("Language")
                            Spacer()
                            Text(AppLanguage(rawValue: appLanguage)?.nativeName ?? "")
                                .foregroundColor(.gray)
                        }
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
