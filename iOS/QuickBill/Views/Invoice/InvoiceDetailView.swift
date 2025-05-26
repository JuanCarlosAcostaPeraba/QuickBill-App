//
//  InvoiceDetailView.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 6/5/25.
//

import SwiftUI

struct InvoiceDetailView: View {
    let invoiceId: String
    
    @StateObject private var vm: InvoiceDetailViewModel
    
    init(invoiceId: String) {
        self.invoiceId = invoiceId
        _vm = StateObject(wrappedValue: InvoiceDetailViewModel(invoiceId: invoiceId))
    }
    
    var body: some View {
        Group {
            if let inv = vm.invoice {
                invoiceContent(for: inv)
            } else {
                loadingView
                    .task { await vm.fetch() }
            }
        }
        .navigationTitle("Invoice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let inv = vm.invoice, inv.status != .paid {
                ToolbarItem(placement: .bottomBar) {
                    Button("Mark as Paid") {
                        Task { await vm.markAsPaid() }
                    }
                    .font(.headline)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if let inv = vm.invoice {
                        Task {
                            let nameDict = Dictionary(uniqueKeysWithValues:
                                vm.products.map { ($0.id, $0.description) })
                            
                            let url = try InvoicePDFBuilder.createPDF(
                                for: inv,
                                businessName: vm.businessName,
                                clientName: vm.clientName,
                                products: inv.productsStack,
                                productNames: nameDict
                            )
                            let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let root = scene.windows.first?.rootViewController {
                                root.present(av, animated: true)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
    }
    
    // MARK: - Extracted sub‑views to lighten body
    @ViewBuilder
    private func invoiceContent(for inv: Invoice) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text(inv.companyName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Issued:")
                    Spacer()
                    Text(inv.issuedAt, style: .date)
                }
                HStack {
                    Text("Due:")
                    Spacer()
                    Text(inv.dueDate, style: .date)
                }
                
                Divider()
                
                VStack(spacing: 8) {
                    amountRow(label: "Subtotal", value: inv.subtotal, currency: inv.currency)
                    amountRow(label: "Tax",      value: inv.taxTotal, currency: inv.currency)
                    amountRow(label: "Discounts",value: inv.discounts, currency: inv.currency)
                    Divider()
                    amountRow(label: "TOTAL",    value: inv.totalAmount, currency: inv.currency, isBold: true)
                }
                
                Divider()
                
                if !inv.productsStack.isEmpty {
                    Text("Products")
                        .font(.headline)
                    
                    ForEach(inv.productsStack, id: \.id) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(vm.productName(for: item.productId))
                                Text("Qty: \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(String(format: "%.2f %@", item.amount, inv.currency))
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Text(inv.status.rawValue.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(inv.status.color)
                    .cornerRadius(4)
            }
            .padding()
        }
    }
    
    private var loadingView: some View {
        ProgressView("Loading…")
    }
    
    // MARK: - Helper Views
    @ViewBuilder
    private func amountRow(label: String,
                           value: Double,
                           currency: String,
                           isBold: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(String(format: "%.2f %@", value, currency))
                .fontWeight(isBold ? .bold : .regular)
        }
    }
}
