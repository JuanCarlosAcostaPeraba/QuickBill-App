//
//  InvoiceDetailViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 11/5/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// View‑model encargado de cargar todos los datos de una factura concreta
@MainActor
final class InvoiceDetailViewModel: ObservableObject {
    
    // MARK: - Published state
    @Published var invoice: Invoice?
    @Published var clientName: String = "—"
    @Published var products: [Product] = []          // catálogo completo (para resolver nombres)
    /// Current status of the invoice (updates independently for UI bindings)
    @Published var status: InvoiceStatus = .pending
    
    // MARK: - Private
    private let invoiceId: String
    private let db = Firestore.firestore()
    
    init(invoiceId: String) {
        self.invoiceId = invoiceId
    }
    
    /// Carga el documento de factura, los datos del cliente y los productos necesarios
    func fetch() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 1) Localizar el negocio del empleado logueado
        let empSnap = try? await db.collectionGroup("employees")
            .whereField("userId", isEqualTo: uid)
            .getDocuments()
        
        guard
            let empDoc     = empSnap?.documents.first,
            let businessRef = empDoc.reference.parent.parent
        else { return }
        
        // 2) Descargar la factura
        let invDoc = try? await businessRef.collection("invoices")
            .document(invoiceId)
            .getDocument()
        
        guard let invData = invDoc?.data() else { return }
        
        // 3) Resolver campos básicos
        guard
            let issuedTs    = invData["issuedAt"]     as? Timestamp,
            let dueTs       = invData["dueDate"]      as? Timestamp,
            let subtotal    = invData["subtotal"]     as? Double,
            let taxTotal    = invData["taxTotal"]     as? Double,
            let discounts   = invData["discounts"]    as? Double,
            let totalAmount = invData["totalAmount"]  as? Double,
            let currency    = invData["currency"]     as? String,
            let clientId    = invData["clientId"]     as? String,
            let employeeId  = invData["employeeId"]   as? String,
            let statusRaw   = invData["status"]       as? String,
            let status      = InvoiceStatus(rawValue: statusRaw)
        else { return }

        // keep UI in sync
        self.status = status
        
        // 4) Traer nombre del cliente
        if let clientDoc = try? await businessRef.collection("clients").document(clientId).getDocument(),
           let clientData = clientDoc.data() {
            clientName = (clientData["companyName"] as? String) ??
                         (clientData["clientName"]  as? String)  ?? "—"
        }
        
        // 5) Traer catálogo de productos (para nombres y precios)
        let prodSnap = try? await businessRef.collection("products").getDocuments()
        if let docs = prodSnap?.documents {
            products = docs.compactMap { doc in
                let d = doc.data()
                guard
                    let desc = d["description"] as? String,
                    let unit = d["unitPrice"]   as? Double
                else { return nil }
                return Product(id: doc.documentID, description: desc, unitPrice: unit)
            }
        }
        
        // 6) Traer stack de productos de la factura
        var stack: [ProductStack] = []
        let stackSnap = try? await businessRef
            .collection("invoices")
            .document(invoiceId)
            .collection("productsStack")
            .getDocuments()
        
        if let sDocs = stackSnap?.documents {
            stack = sDocs.compactMap { doc in
                let d = doc.data()
                guard
                    let productId  = d["productId"]  as? String,
                    let supplyTs   = d["supplyDate"] as? Timestamp,
                    let quantity   = d["quantity"]   as? Int,
                    let amount     = d["amount"]     as? Double,
                    let taxRate    = d["taxRate"]    as? Double,
                    let taxNet     = d["taxNet"]     as? Double
                else { return nil }
                
                return ProductStack(
                    id: doc.documentID,
                    productId: productId,
                    supplyDate: supplyTs.dateValue(),
                    quantity: quantity,
                    amount: amount,
                    taxRate: taxRate,
                    taxNet: taxNet
                )
            }
        }
        
        // 7) Montar el modelo de factura
        let pdfURL      = (invData["pdfURL"] as? String).flatMap(URL.init(string:))
        let deleteAfter = (invData["deleteAfter"] as? Timestamp)?.dateValue()
        
        invoice = Invoice(
            id:           invoiceId,
            companyName:  clientName,
            issuedAt:     issuedTs.dateValue(),
            dueDate:      dueTs.dateValue(),
            amount:       totalAmount,
            subtotal:     subtotal,
            taxTotal:     taxTotal,
            discounts:    discounts,
            totalAmount:  totalAmount,
            currency:     currency,
            clientId:     clientId,
            employeeId:   employeeId,
            pdfURL:       pdfURL,
            deleteAfter:  deleteAfter,
            productsStack: stack,
            status:       status
        )
    }
    
    /// Cambia el estado de la factura a `Paid` en Firestore y actualiza la UI
    func markAsPaid() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            // 1. Buscar el negocio al que pertenece el empleado
            let empSnap = try await db.collectionGroup("employees")
                .whereField("userId", isEqualTo: uid)
                .getDocuments()
            
            guard
                let empDoc      = empSnap.documents.first,
                let businessRef = empDoc.reference.parent.parent
            else { return }
            
            let invoiceRef = businessRef.collection("invoices").document(invoiceId)
            
            // 2. Actualizar el campo `status` en Firestore
            try await invoiceRef.updateData(["status": "Paid"])
            
            // 3. Refrescar el estado local para que la vista cambie sin recargar
            self.status = .paid
            if var current = self.invoice {
                current.status = .paid
                self.invoice = current
            }
        } catch {
            print("Error while marking invoice as paid: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    func productName(for productId: String) -> String {
        products.first(where: { $0.id == productId })?.description ?? "—"
    }
}
