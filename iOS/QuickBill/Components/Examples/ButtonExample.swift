//
//  ButtonExample.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 24/4/25.
//

import SwiftUI

struct ButtonExample: View {
    @State private var tappedCount:Int = 0
    var body: some View {
        Button(
            action: {
                tappedCount += 1
            },
            label: {
                Text("Taps: \(tappedCount)")
                    .frame(width: 100, height: 50)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.title)
                    .bold()
            }
        )
    }
}

#Preview {
    ButtonExample()
}
