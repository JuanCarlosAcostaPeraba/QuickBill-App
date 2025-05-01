//
//  Phase3View.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 27/4/25.
//

import SwiftUI

struct Phase3View: View {
    @Binding var companyName: String
    @Binding var tagline: String
    @Binding var taxId: String
    @Binding var companyEmail: String
    @Binding var companyPhone: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Company name
            TextField("Company name", text: $companyName)
                .autocapitalization(.words)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            
            // Tagline (optional)
            TextField("Tagline (optional)", text: $tagline)
                .autocapitalization(.sentences)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            
            // Tax ID (CIF, VAT, EIN...)
            TextField("Tax ID (CIF, VAT, EIN...)", text: $taxId)
                .autocapitalization(.allCharacters)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            
            // Company email
            TextField("Company email", text: $companyEmail)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
            
            // Company phone
            TextField("Company phone", text: $companyPhone)
                .keyboardType(.phonePad)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
        }
    }
}
