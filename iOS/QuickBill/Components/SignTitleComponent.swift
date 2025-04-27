//
//  SignTitleComponent.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 25/4/25.
//

import SwiftUI

struct SignTitleComponent: View {
    let title: String
    let destinationText: String
    let destination: AnyView
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            HStack {
                Text("or ")
                NavigationLink(destination:{
                    destination
                }){
                    Text(destinationText)
                        .foregroundColor(.blue)
                }
            }
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
        }.foregroundColor(.cyan950).padding(.bottom, 32)
    }
}
