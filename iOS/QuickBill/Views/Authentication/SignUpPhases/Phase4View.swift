//
//  Phase4View.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 27/4/25.
//

import SwiftUI

struct Phase4View: View {
    @Binding var address: String
    @Binding var city: String
    @Binding var country: String
    @Binding var postcode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Address field
            TextField("Address", text: $address)
                .textContentType(.fullStreetAddress)
                .autocapitalization(.words)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            
            // City field
            TextField("City", text: $city)
                .autocapitalization(.words)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            
            // Country field
            TextField("Country", text: $country)
                .autocapitalization(.words)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            
            // Postcode field
            TextField("Postcode", text: $postcode)
                .keyboardType(.default)
                .autocapitalization(.allCharacters)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
        }
    }
}
