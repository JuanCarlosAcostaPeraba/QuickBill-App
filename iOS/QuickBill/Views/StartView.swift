//
//  StartView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 25/4/25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Illustration at top
                Image("startIllustration")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)

                // Headline and subheadline
                VStack(spacing: 4) {
                    Text("Smart billing made simple.")
                        .font(.headline)
                    Text("Everything your business needs, in one place.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                // Sign in button
                NavigationLink(destination: SignInView()) {
                    Text("Sign in to QuickBill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(30)
                }
                .padding(.horizontal)

                // Sign up text button
                NavigationLink(destination: SignUpView()) {
                    Text("Sign up")
                        .font(.headline)
                        .foregroundColor(.black)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}
