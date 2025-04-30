//
//  EmployeesView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EmployeesView: View {
    @StateObject private var viewModel = EmployeesViewModel()
    @State private var showAddEmployee = false
    
    var body: some View {
        NavigationStack {
            if viewModel.employees.isEmpty {
                Text("Empty employee list")
                    .font(.title)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List(viewModel.employees) { employee in
                    NavigationLink(destination: EmployeeView(employee: employee)) {
                        Text(employee.name)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddEmployee) {
            AddEmployeeView(isPresented: $showAddEmployee, viewModel: viewModel)
        }
        .navigationTitle("Employees")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add employee") {
                    showAddEmployee = true
                }
            }
        }
        .onAppear { viewModel.fetchEmployees() }
    }
}
