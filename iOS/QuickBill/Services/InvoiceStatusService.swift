//
//  InvoiceStatusService.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 11/5/25.
//

import Foundation

/// Central service that calculates the “live” status of an invoice on‑device.
struct InvoiceStatusService {

    /// Computes the status that should be displayed right now.
    /// - Parameter invoice: The invoice whose status you want to resolve.
    /// - Returns: `.paid`, `.overdue`, or `.pending` depending on stored status and dueDate.
    static func effectiveStatus(for invoice: Invoice) -> InvoiceStatus {
        // 1.  If Firestore already marks it Paid, keep that.
        if invoice.status == .paid { return .paid }

        // 2.  Compare dueDate with the current device date.
        return invoice.dueDate < Date() ? .overdue : .pending
    }
}
