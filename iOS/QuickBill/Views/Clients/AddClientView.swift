//
//  AddClientView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import SwiftUI

struct AddClientView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ClientsViewModel
    
    @State private var companyName: String = ""
    @State private var clientName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var country: String = ""
    @State private var postcode: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("New Client")) {
                    TextField("Company Name", text: $companyName)
                    TextField("Client Name", text: $clientName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Address", text: $address)
                    TextField("City", text: $city)
                    TextField("Country", text: $country)
                    TextField("Postcode", text: $postcode)
                }
            }
            .navigationTitle("Add Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addClient(
                            companyName: companyName,
                            clientName: clientName,
                            email: email,
                            phone: phone,
                            address: address,
                            city: city,
                            country: country,
                            postcode: postcode
                        )
                        isPresented = false
                    }
                    .disabled(
                        companyName.isEmpty ||
                        clientName.isEmpty ||
                        email.isEmpty ||
                        phone.isEmpty ||
                        address.isEmpty ||
                        city.isEmpty ||
                        country.isEmpty ||
                        postcode.isEmpty
                    )
                }
            }
        }
    }
}
