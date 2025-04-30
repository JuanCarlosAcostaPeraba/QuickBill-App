//
//  CompanyDataView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI

struct CompanyDataView: View {
    @StateObject private var viewModel = CompanyDataViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if viewModel.isEditing {
                        TextField("Company Name", text: $viewModel.companyName)
                        TextField("Tagline", text: $viewModel.tagline)
                        TextField("Tax ID", text: $viewModel.taxId)
                        TextField("Company Email", text: $viewModel.companyEmail)
                            .keyboardType(.emailAddress)
                        TextField("Company Phone", text: $viewModel.companyPhone)
                            .keyboardType(.phonePad)
                        TextField("Address", text: $viewModel.address)
                        TextField("City", text: $viewModel.city)
                        TextField("Country", text: $viewModel.country)
                        TextField("Postcode", text: $viewModel.postcode)
                    } else {
                        HStack { Text("Company Name"); Spacer(); Text(viewModel.companyName) }
                        HStack { Text("Tagline"); Spacer(); Text(viewModel.tagline) }
                        HStack { Text("Tax ID"); Spacer(); Text(viewModel.taxId) }
                        HStack { Text("Company Email"); Spacer(); Text(viewModel.companyEmail) }
                        HStack { Text("Company Phone"); Spacer(); Text(viewModel.companyPhone) }
                        HStack { Text("Address"); Spacer(); Text(viewModel.address) }
                        HStack { Text("City"); Spacer(); Text(viewModel.city) }
                        HStack { Text("Country"); Spacer(); Text(viewModel.country) }
                        HStack { Text("Postcode"); Spacer(); Text(viewModel.postcode) }
                    }
                }
            }
            .navigationTitle("Company Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isEditing {
                        Button("Save") { viewModel.saveChanges() }
                    } else {
                        Button("Edit") { viewModel.isEditing = true }
                    }
                }
            }
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

#Preview {
    CompanyDataView()
}
