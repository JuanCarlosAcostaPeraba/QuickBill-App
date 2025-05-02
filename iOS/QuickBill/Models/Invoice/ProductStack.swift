//
//  ProductStack.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 2/5/25.
//

import Foundation

struct ProductStack: Identifiable {
    let id: String
    let productId: String
    let supplyDate: Date
    let quantity: Int
    let amount: Double
    let taxRate: Double
    let taxNet: Double
}
