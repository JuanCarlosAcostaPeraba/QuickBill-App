//
//  MenuView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 24/4/25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        VStack {
            NavigationStack {
                Image("Start-image")
                    .padding(.bottom, 50)
                VStack {
                    Text("Smart billing made simple.")
                    Text("Everything your business needs, in one place.")
                }.padding(.bottom, 50).foregroundColor(.zinc500)
                NavigationLink(destination:{
                    // TODO: Add sign in view
                }){
                    Text("Sign in to QuickBill")
                        .foregroundColor(.cyan950)
                        .font(.headline)
                        .padding(.horizontal, 70)
                        .padding(.vertical, 15)
                        .foregroundColor(.black)
                        .background(.blue300)
                        .cornerRadius(50)
                        .shadow(
                            color: .blue300.opacity(0.5),
                            radius: 10,
                            x: 0,
                            y: 10
                        )
                }
                Spacer()
                    .frame(height: 30)
                NavigationLink(destination:{
                    // TODO: Add sign up view
                }){
                    Text("Sign up")
                        .foregroundColor(.cyan950)
                        .font(.headline)
                }
            }
        }.padding(.horizontal, 16)
    }
}

#Preview {
    MenuView()
}
