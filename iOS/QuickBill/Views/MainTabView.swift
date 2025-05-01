//
//  MainTabView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedTab: TabItem = .home
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView()
                case .products:
                    ProductsView()
                case .add:
                    //AddInvoiceView()
                    EmptyView()
                case .clients:
                    ClientsView()
                case .settings:
                    SettingsView(auth: _auth)
                }
            }
            NavBarComponent(selectedTab: $selectedTab)
        }
    }
}
