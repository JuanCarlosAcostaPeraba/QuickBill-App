//
//  TabItem.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import SwiftUI

enum TabItem: String, CaseIterable, Identifiable {
    case home = "Home"
    case products = "Products"
    case add = "Add"
    case clients = "Clients"
    case settings = "Settings"
    
    var id: Self { self }
    
    /// System image name for each tab
    var iconName: String {
        switch self {
        case .home:      return "house"
        case .products:  return "doc.plaintext"
        case .add:       return "plus"
        case .clients:   return "person.2"
        case .settings:  return "gearshape"
        }
    }
}
