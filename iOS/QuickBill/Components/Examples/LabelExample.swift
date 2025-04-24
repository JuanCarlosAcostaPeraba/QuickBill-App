//
//  LabelExample.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 24/4/25.
//

import SwiftUI

struct LabelExample: View {
    var body: some View {
        Label(
            title: {
                Text("Hello, World!")
            },
            icon: {
                Image(systemName: "figure.walk")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
        )
    }
}

#Preview {
    LabelExample()
}
