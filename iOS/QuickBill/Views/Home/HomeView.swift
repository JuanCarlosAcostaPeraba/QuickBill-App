//
//  HomeViewContent.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = InvoiceListViewModel()
    @State private var showFiltersSheet = false
    @State private var compactMode = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    if viewModel.showSearch {
                        TextField("Search invoices...", text: $viewModel.searchText)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        // Botón filtros avanzados
                        Button {
                            showFiltersSheet = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(.vertical, 6.5)
                        }
                        // Botón modo compacto / tarjetas
                        Button {
                            withAnimation { compactMode.toggle() }
                        } label: {
                            Image(systemName: compactMode ? "list.bullet" : "square.grid.2x2")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(.vertical, 6.5)
                        }
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
                        let cols = compactMode ? [GridItem(.flexible())]
                                               : [GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: cols, spacing: 16) {
                            ForEach(viewModel.filteredInvoices) { invoice in
                                NavigationLink {
                                    InvoiceDetailView(invoiceId: invoice.id)
                                } label: {
                                    InvoiceCardComponent(
                                        invoice: invoice,
                                        clientName: viewModel.getClientName(for: invoice.clientId)
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .sheet(isPresented: $showFiltersSheet) {
                InvoiceAdvancedFilterSheet(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchInvoices()
            }
        }
    }
}

struct InvoiceAdvancedFilterSheet: View {
    @ObservedObject var viewModel: InvoiceListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            formContent
                .navigationTitle("Filters")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
    
    /// Extracted form to help the compiler type‑check faster
    private var formContent: some View {
        Form {
            Section(header: Text("Status")) {
                Picker("Status", selection: $viewModel.selectedStatus) {
                    Text("All").tag(InvoiceStatus.all)
                    ForEach(InvoiceStatus.allCases.filter { $0 != .all }, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
            }
            // TODO: Add more filters (date, amount)
        }
    }
}
