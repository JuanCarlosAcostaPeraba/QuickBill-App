//
//  InvoiceStatus.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import SwiftUI

enum InvoiceStatus: String, CaseIterable {
    case all = "All"
    case paid = "Paid"
    case pending = "Pending"
    case overdue = "Overdue"
    
    var iconName: String {
        switch self {
        case .all: return "tray"
        case .paid: return "dollarsign.circle"
        case .pending: return "calendar"
        case .overdue: return "bell"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color.blue
        case .paid: return Color.green
        case .pending: return Color.purple
        case .overdue: return Color.red
        }
    }
}
