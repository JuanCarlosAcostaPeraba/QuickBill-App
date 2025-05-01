//
//  ProfileView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if viewModel.isEditing {
                        TextField("Full Name", text: $viewModel.fullName)
                        TextField("Email", text: $viewModel.email)
                            .foregroundColor(.gray)
                            .disabled(true)
                        TextField("Phone", text: $viewModel.phone)
                    } else {
                        HStack {
                            Text("Full Name")
                            Spacer()
                            Text(viewModel.fullName)
                        }
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(viewModel.email)
                        }
                        HStack {
                            Text("Phone")
                            Spacer()
                            Text(viewModel.phone)
                        }
                    }
                }
                Section {
                    Button("Change Password") {
                        viewModel.resetPassword()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isEditing {
                        Button("Save") {
                            viewModel.saveChanges()
                        }
                    } else {
                        Button("Edit") {
                            viewModel.isEditing = true
                        }
                    }
                }
            }
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
