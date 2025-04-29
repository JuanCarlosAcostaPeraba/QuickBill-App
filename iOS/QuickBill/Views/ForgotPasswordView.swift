//
//  ForgotPasswordView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 27/4/25.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Back button
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(.horizontal)

            // Title and subtitle
            VStack(spacing: 8) {
                Text("Did you forget your Password?")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("We’ll assign you a new one. Enter your email address and we will send you the link to retrieve it.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Email field
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)

            // Recover button
            Button {
                Task {
                    do {
                        try await Auth.auth().sendPasswordReset(withEmail: email)
                        alertMessage = "A password reset link has been sent to \(email)."
                    } catch {
                        alertMessage = error.localizedDescription
                    }
                    showAlert = true
                }
            } label: {
                Text("Recover Password")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.horizontal)

            Spacer()
        }
        .alert("Notice", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .navigationBarHidden(true)
    }
}
