//
//  PrincipalButtonComponent.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 25/4/25.
//

import SwiftUI

struct PrincipalNavButtonComponent: View {
    let buttonText: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination:{
            destination
        }){
            Text(buttonText)
                .foregroundColor(.cyan950)
                .font(.headline)
                .padding(.horizontal, 70)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                .background(.blue300)
                .cornerRadius(50)
        }
    }
}
