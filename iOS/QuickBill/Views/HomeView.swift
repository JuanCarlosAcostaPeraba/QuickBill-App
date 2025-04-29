//
//  HomeView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 25/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @StateObject private var viewModel = InvoiceListViewModel()
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar and toggle button in one row
            HStack {
                if viewModel.showSearch {
                    TextField("Search invoices...", text: $viewModel.searchText)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                Spacer()
                Button(action: {
                    viewModel.showSearch.toggle()
                }) {
                    Image(systemName: viewModel.showSearch ? "xmark" : "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(.vertical, 6.5)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Filter bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(InvoiceStatus.allCases, id: \.self) { status in
                        Button {
                            withAnimation { viewModel.selectedStatus = status }
                        } label: {
                            HStack {
                                Image(systemName: status.iconName)
                                Text(status.rawValue)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .foregroundColor(viewModel.selectedStatus == status ? .white : .gray)
                            .background(viewModel.selectedStatus == status ? status.color : Color.gray.opacity(0.2))
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            // Invoice grid
            if viewModel.filteredInvoices.isEmpty {
                Text("No invoices")
                    .font(.title)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.filteredInvoices) { invoice in
                            InvoiceCardComponent(invoice: invoice)
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
            // Bottom navigation bar
            BarNavComponent(selectedTab: $selectedTab)
        }
        .onAppear {
            viewModel.fetchInvoices()
        }
    }
}

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(InvoiceListViewModel())
    }
}
