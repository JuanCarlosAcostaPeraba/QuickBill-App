//
//  ProductsViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 1/5/25.
//

import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var searchText: String = ""
    private let db = Firestore.firestore()
    private var currentUserId: String { Auth.auth().currentUser?.uid ?? "" }
    
    /// Fetches all products under the current user's business
    func fetchProducts() {
        let empQuery = db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
        empQuery.getDocuments { empSnap, empErr in
            if let empErr = empErr {
                print("Error finding employee record: \(empErr)")
                return
            }
            guard let empDoc = empSnap?.documents.first,
                  let businessRef = empDoc.reference.parent.parent else {
                print("Business not found for user \(self.currentUserId)")
                return
            }
            businessRef.collection("products").getDocuments { snap, err in
                if let err = err {
                    print("Error fetching products: \(err)")
                    return
                }
                let items = snap?.documents.compactMap { doc -> Product? in
                    let data = doc.data()
                    guard let desc = data["description"] as? String,
                          let price = data["unitPrice"] as? Double else {
                        return nil
                    }
                    return Product(id: doc.documentID, description: desc, unitPrice: price)
                } ?? []
                DispatchQueue.main.async {
                    self.products = items
                }
            }
        }
    }
    
    /// Adds a new product under the business
    func addProduct(description: String, unitPrice: Double) {
        let empQuery = db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
        empQuery.getDocuments { empSnap, empErr in
            if let empErr = empErr {
                print("Error finding employee record: \(empErr)")
                return
            }
            guard let empDoc = empSnap?.documents.first,
                  let businessRef = empDoc.reference.parent.parent else {
                print("Business not found for user \(self.currentUserId)")
                return
            }
            let newRef = businessRef.collection("products").document()
            newRef.setData([
                "description": description,
                "unitPrice": unitPrice
            ]) { error in
                if let error = error {
                    print("Error adding product: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.fetchProducts()
                    }
                }
            }
        }
    }
    
    /// Deletes the specified product
    func deleteProduct(_ product: Product) {
        let empQuery = db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
        empQuery.getDocuments { empSnap, empErr in
            if let empErr = empErr {
                print("Error finding employee record: \(empErr)")
                return
            }
            guard let empDoc = empSnap?.documents.first,
                  let businessRef = empDoc.reference.parent.parent else {
                print("Business not found for user \(self.currentUserId)")
                return
            }
            businessRef.collection("products").document(product.id).delete { err in
                if let err = err {
                    print("Error deleting product: \(err)")
                } else {
                    DispatchQueue.main.async {
                        self.fetchProducts()
                    }
                }
            }
        }
    }
    
    /// Updates an existing product’s description and unit price
    func updateProduct(description: String, unitPrice: Double, for productId: String) {
        // 1) Find this user's business reference
        let empQuery = db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
        empQuery.getDocuments { empSnap, empErr in
            if let empErr = empErr {
                print("Error finding employee record: \(empErr)")
                return
            }
            guard let empDoc = empSnap?.documents.first,
                  let businessRef = empDoc.reference.parent.parent else {
                print("Business not found for user \(self.currentUserId)")
                return
            }
            // 2) Update the product document
            businessRef.collection("products").document(productId).updateData([
                "description": description,
                "unitPrice": unitPrice
            ]) { error in
                if let error = error {
                    print("Error updating product: \(error)")
                } else {
                    // Refresh the list after update
                    DispatchQueue.main.async {
                        self.fetchProducts()
                    }
                }
            }
        }
    }
}
