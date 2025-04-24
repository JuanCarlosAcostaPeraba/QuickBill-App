//
//  MenuView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 24/4/25.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image("Start-image")
                    .padding(.bottom, 50)
                VStack {
                    Text("Smart billing made simple.")
                    Text("Everything your business needs, in one place.")
                }.padding(.bottom, 50).foregroundColor(.gray)
                NavigationLink {
                    
                } label: {
                    Text("Sign in to QuickBill")
                        .foregroundColor(.black)
                        .font(.headline)
                        .padding()
                        .padding(.horizontal, 50)
                        .background(.blue.opacity(0.3))
                        .foregroundColor(.black)
                        .cornerRadius(50)
                        .padding(.vertical, 20)
                }
                NavigationLink {
                    
                } label: {
                    Text("Sign up")
                        .foregroundColor(.black)
                        .font(.headline)
                }
            }.padding(.horizontal, 16)
        }
    }
}

#Preview {
    MenuView()
}
