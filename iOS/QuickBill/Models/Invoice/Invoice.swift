//
//  Invoice.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 29/4/25.
//

import Foundation

struct Invoice: Identifiable {
    let id: String
    let companyName: String
    let issuedAt: Date
    let dueDate: Date
    let amount: Double
    let subtotal: Double
    let taxTotal: Double
    let discounts: Double
    let totalAmount: Double
    let currency: String
    let clientId: String
    let employeeId: String
    let pdfURL: URL?
    let deleteAfter: Date?
    let productsStack: [ProductStack]
    var status: InvoiceStatus
}
