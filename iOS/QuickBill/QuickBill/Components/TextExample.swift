//
//  TextExample.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 23/4/25.
//

import SwiftUI

struct TextExample: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .font(.title)
        Text("This is a test")
            .font(.system(
                size: 20,
                weight: .bold,
                design: .rounded
            ))
            .foregroundColor(.blue)
            .frame(
                width: 200,
                height: 100,
                alignment: .center
            )
            .background(Color.yellow)
    }
}

#Preview {
    TextExample()
}
