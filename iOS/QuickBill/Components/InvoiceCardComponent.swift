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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 1. Company name
            Text(invoice.companyName)
                .font(.headline)
            
            // 2. Issued date formatted
            Text(invoice.issuedAt, style: .date)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 3. Total amount with currency
            Text(String(format: "%.2f %@", invoice.totalAmount, invoice.currency))
                .font(.title2)
                .fontWeight(.bold)
            
            // 4. Status badge
            Text(invoice.status.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(4)
                .background(invoice.status.color)
                .cornerRadius(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
