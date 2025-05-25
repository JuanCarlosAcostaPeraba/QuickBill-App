//
//  EditProductView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import SwiftUI

struct EditProductView: View {
    let product: Product
    @ObservedObject var viewModel: ProductsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var descriptionText: String
    @State private var unitPriceText: String
    
    init(product: Product, viewModel: ProductsViewModel) {
        self.product = product
        self.viewModel = viewModel
        _descriptionText = State(initialValue: product.description)
        _unitPriceText = State(initialValue: String(format: "%.2f", product.unitPrice))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Edit Product")) {
                    TextField("Description", text: $descriptionText)
                    TextField("Unit Price", text: $unitPriceText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let price = Double(unitPriceText) ?? product.unitPrice
                        viewModel.updateProduct(description: descriptionText, unitPrice: price, for: product.id)
                        dismiss()
                    }
                    .disabled(descriptionText.isEmpty || unitPriceText.isEmpty)
                }
            }
        }
    }
}
