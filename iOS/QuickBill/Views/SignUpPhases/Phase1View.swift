//
//  Phase1View.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 27/4/25.
//

import SwiftUI

struct Phase1View: View {
    @Binding var email: String
    @Binding var password: String
    @State private var showPassword: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Email field
            TextField("Enter your email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)

            // Password field with toggle
            ZStack {
                if showPassword {
                    TextField("Enter your password", text: $password)
                } else {
                    SecureField("Enter your password", text: $password)
                }
            }
            .keyboardType(.default)
            .textContentType(.password)
            .autocapitalization(.none)
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16),
                alignment: .trailing
            )

            // Hint text
            Text("Password must be 6+ characters")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
