//
//  MainTabView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var invoicesVM = InvoiceListViewModel()
    @State private var selectedTab: TabItem = .home
    var body: some View {
        VStack(spacing: 0) {
            // Main content for each tab
            ZStack {
                switch selectedTab {
                case .home:
                    // Extracted home content
                    HomeViewContent(viewModel: invoicesVM)
                case .products:
                    //ProductsView()
                    EmptyView()
                case .add:
                    //AddInvoiceView()
                    EmptyView()
                case .clients:
                    //ClientsView()
                    EmptyView()
                case .settings:
                    SettingsViewContent(auth: _auth)
                }
            }
            NavBarComponent(selectedTab: $selectedTab)
        }
        .onAppear {
            invoicesVM.fetchInvoices()
        }
    }
}
