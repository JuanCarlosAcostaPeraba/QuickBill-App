//
//  AddProductView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import SwiftUI

struct AddProductView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ProductsViewModel

    @State private var descriptionText: String = ""
    @State private var unitPriceText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("New Product")) {
                    TextField("Description", text: $descriptionText)
                    TextField("Unit Price", text: $unitPriceText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let price = Double(unitPriceText) ?? 0
                        viewModel.addProduct(description: descriptionText, unitPrice: price)
                        isPresented = false
                    }
                    .disabled(descriptionText.isEmpty || unitPriceText.isEmpty)
                }
            }
        }
    }
}
