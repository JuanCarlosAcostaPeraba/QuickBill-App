//
//  ClientView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import SwiftUI

struct ClientView: View {
    let client: Client
    @StateObject private var viewModel: ClientViewModel
    
    init(client: Client) {
        self.client = client
        _viewModel = StateObject(wrappedValue: ClientViewModel(client: client))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if viewModel.isEditing {
                        TextField("Company Name", text: $viewModel.companyName)
                        TextField("Client Name", text: $viewModel.clientName)
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                        TextField("Phone", text: $viewModel.phone)
                            .keyboardType(.phonePad)
                        TextField("Address", text: $viewModel.address)
                        TextField("City", text: $viewModel.city)
                        TextField("Country", text: $viewModel.country)
                        TextField("Postcode", text: $viewModel.postcode)
                    } else {
                        HStack { Text("Company Name"); Spacer(); Text(viewModel.companyName)}
                        HStack { Text("Client Name"); Spacer(); Text(viewModel.clientName) }
                        HStack { Text("Email"); Spacer(); Text(viewModel.email) }
                        HStack { Text("Phone"); Spacer(); Text(viewModel.phone) }
                        HStack { Text("Address"); Spacer(); Text(viewModel.address) }
                        HStack { Text("City"); Spacer(); Text(viewModel.city) }
                        HStack { Text("Country"); Spacer(); Text(viewModel.country) }
                        HStack { Text("Postcode"); Spacer(); Text(viewModel.postcode) }
                    }
                }
            }
            .navigationTitle(viewModel.clientName.isEmpty ? "Client" : viewModel.clientName)
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
