//
//  AddInvoiceView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 02/05/25.
//

import SwiftUI

struct AddInvoiceView: View {
    @StateObject private var viewModel = AddInvoiceViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showClientPicker: Bool = false
    @State private var clientSearchText: String = ""
    @State private var selectedLineItemIndex: Int? = nil
    @State private var showProductPicker: Bool = false
    @State private var productSearchText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                dateSection
                clientSection
                productsSection
            }
            .navigationTitle("Add Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveInvoice { result in
                            switch result {
                            case .success:
                                viewModel.resetForm()
                            case .failure(let error):
                                viewModel.alertMessage = error.localizedDescription
                                viewModel.showAlert = true
                            }
                        }
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
        .onAppear {
            viewModel.fetchClients()
            viewModel.fetchProducts()
            viewModel.addLineItem()
        }
        .sheet(isPresented: $showClientPicker) {
            clientPickerSheet
        }
        .sheet(isPresented: $showProductPicker) {
            if let idx = selectedLineItemIndex {
                productPickerSheet(for: idx)
            }
        }
    }
    
    // MARK: - Form Sections
    
    private var dateSection: some View {
        Section(header: Text("Dates")) {
            DatePicker("Issued At", selection: $viewModel.issuedAt, displayedComponents: .date)
            DatePicker("Due Date", selection: $viewModel.dueDate, displayedComponents: .date)
        }
    }
    
    private var clientSection: some View {
        Section(header: Text("Client")) {
            Button {
                showClientPicker = true
            } label: {
                HStack {
                    Text("Client")
                    Spacer()
                    if let selected = viewModel.clients.first(where: { $0.id == viewModel.selectedClientId }) {
                        Text("\(selected.companyName) - \(selected.clientName)")
                            .foregroundColor(.primary)
                    } else {
                        Text("Select client")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var productsSection: some View {
        Section(header: Text("Products")) {
            ForEach(viewModel.lineItems.indices, id: \.self) { idx in
                let itemBinding = $viewModel.lineItems[idx]
                VStack(alignment: .leading) {
                    Button {
                        viewModel.fetchProducts()
                        selectedLineItemIndex = idx
                        showProductPicker = true
                    } label: {
                        HStack {
                            Text("Product")
                            Spacer()
                            if let prod = viewModel.products.first(where: { $0.id == itemBinding.productId.wrappedValue }) {
                                Text("\(prod.description) - \(String(format: "%.2f", prod.unitPrice))€")
                                    .foregroundColor(.primary)
                            } else {
                                Text("Select product")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    TextField("Quantity", text: itemBinding.quantityText)
                        .keyboardType(.numberPad)
                    TextField("Tax Rate (%)", text: itemBinding.taxRateText)
                        .keyboardType(.decimalPad)
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.lineItems.remove(at: idx)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            Button("Add Product") {
                viewModel.addLineItem()
            }
        }
    }
    
    // MARK: - Sheet Subviews
    
    private var clientPickerSheet: some View {
        NavigationStack {
            List {
                ForEach(viewModel.clients.filter {
                    clientSearchText.isEmpty ||
                    $0.clientName.lowercased().contains(clientSearchText.lowercased())
                }) { client in
                    Button("\(client.companyName) - \(client.clientName)") {
                        viewModel.selectedClientId = client.id
                        showClientPicker = false
                        clientSearchText = ""
                    }
                }
            }
            .searchable(text: $clientSearchText, prompt: "Search clients")
            .navigationTitle("Select Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showClientPicker = false }
                }
            }
        }
    }
    
    private func productPickerSheet(for itemIndex: Int) -> some View {
        NavigationStack {
            VStack {
                TextField("Search products", text: $productSearchText)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                List {
                    ForEach(viewModel.products.filter {
                        productSearchText.isEmpty ||
                        $0.description.lowercased().contains(productSearchText.lowercased()) ||
                        String(format: "%.2f", $0.unitPrice).contains(productSearchText)
                    }) { product in
                        Button {
                            viewModel.lineItems[itemIndex].productId = product.id
                            showProductPicker = false
                            productSearchText = ""
                        } label: {
                            HStack {
                                Text(product.description)
                                Spacer()
                                Text("\(String(format: "%.2f", product.unitPrice))€")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationTitle("Select Product")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showProductPicker = false
                        }
                    }
                }
            }
        }
    }
}
