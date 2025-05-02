//
//  InvoiceLineItem.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 2/5/25.
//

import Foundation

struct InvoiceLineItem: Identifiable {
    let id = UUID()
    var productId: String = ""
    var amountText: String = ""
    var quantityText: String = ""
    var taxRateText: String = ""
}
