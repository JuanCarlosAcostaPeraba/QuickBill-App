//
//  EmployeesView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI

struct EmployeesView: View {
    @StateObject private var viewModel = EmployeesViewModel()
    @State private var showAddEmployee = false
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            
            let filtered = searchText.isEmpty
            ? viewModel.employees
            : viewModel.employees.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            
            List {
                if filtered.isEmpty {
                    Text("Empty employee list")
                        .font(.title)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(filtered) { employee in
                        NavigationLink(destination: EmployeeView(employee: employee)) {
                            Text(employee.name)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteEmployee(employee: employee)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search"
            )
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
