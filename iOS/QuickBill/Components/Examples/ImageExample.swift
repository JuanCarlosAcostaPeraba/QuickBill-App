//
//  ImageExample.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 24/4/25.
//

import SwiftUI

struct ImageExample: View {
    var body: some View {
        Image("Start-image")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
        Image(systemName: "figure.walk")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            
    }
}

#Preview {
    ImageExample()
}
