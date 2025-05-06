//
//  InvoiceCardComponent.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//

import SwiftUI
import Foundation

struct InvoiceCardComponent: View {
    let invoice: Invoice
    let clientName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // 1. Company name
                Text(invoice.companyName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()

                // 1. Client name
                Text(clientName)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
            }
            
            // 2. Issued date formatted
            Text(invoice.issuedAt, style: .date)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(alignment: .trailing, spacing: 6) {
                // 3. Total amount with currency
                Text(String(format: "%.2f %@", invoice.totalAmount, invoice.currency))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                // 4. Status badge
                Text(invoice.status.rawValue)
                    .textCase(.uppercase)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(invoice.status.color)
                    .cornerRadius(4)
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
        )
        .cornerRadius(8)
    }
}
