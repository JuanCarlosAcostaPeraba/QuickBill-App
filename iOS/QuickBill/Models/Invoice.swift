//
//  Invoice.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//

struct Invoice: Identifiable {
    let id: String
    let companyName: String
    let period: String
    let amount: Double
    let currency: String
    let status: InvoiceStatus
}
