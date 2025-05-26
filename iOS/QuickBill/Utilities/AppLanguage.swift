//
//  AppLanguage.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 25/5/25.
//

import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    var nativeName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
}
