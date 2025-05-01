//
//  Client.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import SwiftUI

struct Client: Identifiable {
    let id: String
    let companyName: String
    let clientName: String
    let email: String
    let phone: String
    let address: String
    let city: String
    let country: String
    let postcode: String
}
