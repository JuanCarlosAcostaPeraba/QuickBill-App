//
//  HomeViewContent.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI

struct HomeViewContent: View {
    @ObservedObject var viewModel: InvoiceListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(InvoiceStatus.allCases, id: \.self) { status in
                        Button {
                            withAnimation(.easeInOut) {
                                viewModel.selectedStatus = status
                            }
                        } label: {
                            Group {
                                if viewModel.selectedStatus == status {
                                    HStack(spacing: 8) {
                                        Image(systemName: status.iconName)
                                            .font(.title)
                                        Text(status.rawValue)
                                    }
                                } else {
                                    Image(systemName: status.iconName)
                                        .font(.title)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .foregroundColor(viewModel.selectedStatus == status ? .white : .gray)
                            .background(viewModel.selectedStatus == status ? status.color : Color.gray.opacity(0.2))
                            .cornerRadius(16)
                            .frame(minWidth: viewModel.selectedStatus == status ? 80 : 40, minHeight: 40)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedStatus)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
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
        }
        .onAppear {
            viewModel.fetchInvoices()
        }
    }
}
