//
//  EmployeeView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI

struct EmployeeView: View {
    let employee: Employee
    @StateObject private var viewModel: EmployeeViewModel

    init(employee: Employee) {
        self.employee = employee
        _viewModel = StateObject(wrappedValue: EmployeeViewModel(employee: employee))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if viewModel.isEditing {
                        TextField("Name", text: $viewModel.name)
                        TextField("Email", text: $viewModel.email)
                            .disabled(true)
                        TextField("Phone", text: $viewModel.phone)
                        Toggle("Admin", isOn: $viewModel.isAdmin)
                            .padding(.vertical, 4)
                    } else {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(viewModel.name)
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
                        HStack {
                            Text("Role")
                            Spacer()
                            Text(viewModel.isAdmin ? "admin" : "employee")
                        }
                    }
                } footer: {
                    EmptyView()
                }
            }
            .navigationTitle(employee.name)
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
