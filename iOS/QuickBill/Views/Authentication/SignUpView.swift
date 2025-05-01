//
//  SignUpView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 25/4/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // App title at top
                Text("QuickBill")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                
                Spacer()

                // Centered content: header + phase-specific view
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Join QuickBill")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        HStack(spacing: 0) {
                            Text(" or ")
                                .font(.title2)
                                .fontWeight(.bold)
                            NavigationLink("Sign in", destination: SignInView())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }

                    // Phase content
                    Group {
                        switch viewModel.step {
                        case 1:
                            Phase1View(email: $viewModel.email,
                                       password: $viewModel.password)
                        case 2:
                            Phase2View(fullName: $viewModel.fullName,
                                       phone: $viewModel.phone,
                                       rememberMe: $viewModel.rememberMe)
                        case 3:
                            Phase3View(companyName: $viewModel.companyName,
                                       tagline: $viewModel.tagline,
                                       taxId: $viewModel.taxId,
                                       companyEmail: $viewModel.companyEmail,
                                       companyPhone: $viewModel.companyPhone)
                        case 4:
                            Phase4View(address: $viewModel.address,
                                       city: $viewModel.city,
                                       country: $viewModel.country,
                                       postcode: $viewModel.postcode)
                        default:
                            EmptyView()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()

                // Continue / Join button at bottom
                Button(action: viewModel.nextStep) {
                    Text(viewModel.step < 4 ? "Continue" : "Join")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text("\(viewModel.step)/4")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal)
            .alert(viewModel.alertTitle,
                   isPresented: $viewModel.showAlert,
                   actions: { Button("OK", role: .cancel) {} },
                   message: { Text(viewModel.alertMessage) })
            .navigationBarHidden(true)
            .onChange(of: viewModel.navigateToHome) {
                if viewModel.navigateToHome {
                    auth.isSignedIn = true
                }
            }
        }
    }
}
