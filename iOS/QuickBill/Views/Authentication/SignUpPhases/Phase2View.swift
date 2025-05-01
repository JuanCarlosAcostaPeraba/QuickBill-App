//
//  Phase2View.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 27/4/25.
//

import SwiftUI

struct Phase2View: View {
    @Binding var fullName: String
    @Binding var phone: String
    @Binding var rememberMe: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Full name field
            TextField("Full name", text: $fullName)
                .autocapitalization(.words)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)

            // Phone number field
            TextField("Phone number", text: $phone)
                .keyboardType(.phonePad)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
        }
    }
}
