//
//  AddEmployeeView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI

struct AddEmployeeView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: EmployeesViewModel
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var isAdmin: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("New Employee")) {
                    TextField("Employee Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    Toggle("Admin", isOn: $isAdmin)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("Add Employee")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addEmployee(name: name, email: email, phone: phone,
                                              role: isAdmin ? "admin" : "employee")
                        isPresented = false
                    }
                    .disabled(name.isEmpty || email.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}
