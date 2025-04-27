//
//  TextFieldExample.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 24/4/25.
//

import SwiftUI

struct TextFieldExample: View {
    @State private var email: String = ""
    @State private var password: String = ""
    var body: some View {
        VStack {
            TextField("Enter your email", text: $email)
                .keyboardType(.emailAddress)
                .padding(16)
                .background(.gray.opacity(0.1))
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .cornerRadius(16)
                .onChange(of: email) { oldValue, newValue in
                    print("Old Value: \(oldValue), New Value: \(newValue)")
                }
            SecureField("Enter your password", text: $password)
                .keyboardType(.emailAddress)
                .padding(16)
                .background(.gray.opacity(0.1))
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .cornerRadius(16)
                .onChange(of: password) { oldValue, newValue in
                    print("Old Value: \(oldValue), New Value: \(newValue)")
                }
        }.padding()
    }
}

#Preview {
    TextFieldExample()
}
