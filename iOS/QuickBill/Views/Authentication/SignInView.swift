//
//  SignInView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 25/4/25.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 16) {
                Text("QuickBill")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                Spacer()
                
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
                
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                
                ZStack {
                    if viewModel.showPassword {
                        TextField("Password", text: $viewModel.password)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                    }
                }
                .keyboardType(.default)
                .textContentType(.password)
                .autocapitalization(.none)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    Button(action: { viewModel.showPassword.toggle() }) {
                        Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                        .padding(.trailing, 16),
                    alignment: .trailing
                )
                
                NavigationLink(destination: ForgotPasswordView()) {
                    Text("Forgot password?")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.signIn()
                        if viewModel.didSignIn {
                            auth.isSignedIn = true
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
            .alert("Sign in Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .navigationBarBackButtonHidden()
        }
    }
}
