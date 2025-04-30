//
//  SignInView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 25/4/25.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {

            VStack(alignment: .leading, spacing: 16) {
                // App title (toolbar handles this, but keep if needed)
                Text("QuickBill")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                Spacer()

                // Header
                VStack(alignment: .leading, spacing: 0) {
                    Text("Sign in")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    HStack(spacing: 0) {
                        Text(" or ")
                            .font(.title2)
                            .fontWeight(.bold)
                        NavigationLink("Join QuickBill", destination: SignUpView())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }

                // Email field
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)

                // Password field with toggle
                ZStack {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
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

                // Forgot password link
                NavigationLink(destination: ForgotPasswordView()) {
                    Text("Forgot password?")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                }
                
                Spacer()

                // Sign in button
                Button(action: {
                    Task {
                        do {
                            _ = try await Auth.auth().signIn(withEmail: email, password: password)
                            auth.isSignedIn = true
                        } catch {
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                }) {
                    Text("Sign in")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(30)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.horizontal)
            .alert("Sign in Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .navigationBarBackButtonHidden()
        }
    }
}
