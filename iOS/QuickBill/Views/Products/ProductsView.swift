//
//  ProductsView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import SwiftUI

struct ProductsView: View {
    @StateObject private var viewModel = ProductsViewModel()
    @State private var showAddProduct = false
    @State private var productToEdit: Product? = nil
    
    private var filtered: [Product] {
        if viewModel.searchText.isEmpty {
            return viewModel.products
        }
        let lower = viewModel.searchText.lowercased()
        return viewModel.products.filter {
            $0.description.lowercased().contains(lower) ||
            String(format: "%.2f", $0.unitPrice).contains(lower)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    Text("Empty product list")
                        .font(.title)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(filtered) { product in
                        HStack {
                            Text(product.description)
                            Spacer()
                            Text("\(String(format: "%.2f", product.unitPrice))€")
                        }
                        .swipeActions(edge: .trailing) {
                            // Edit button
                            Button {
                                productToEdit = product
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                            
                            Button(role: .destructive) {
                                viewModel.deleteProduct(product)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search"
            )
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add product") {
                        showAddProduct = true
                    }
                }
            }
            .sheet(isPresented: $showAddProduct) {
                AddProductView(isPresented: $showAddProduct, viewModel: viewModel)
            }
            .sheet(item: $productToEdit) { product in EditProductView(product: product, viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchProducts()
            }
        }
    }
}
