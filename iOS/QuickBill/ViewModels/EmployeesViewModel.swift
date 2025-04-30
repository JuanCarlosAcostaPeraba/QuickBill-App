//
//  EmployeesViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 30/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class EmployeesViewModel: ObservableObject {
    @Published var employees: [Employee] = []
    private let db = Firestore.firestore()
    private var currentUserId: String { Auth.auth().currentUser?.uid ?? "" }

    func fetchEmployees() {
        // 1) Find this user's business reference
        let empQuery = db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
        empQuery.getDocuments { empSnap, empErr in
            if let empErr = empErr {
                print("Error finding current employee record: \(empErr)")
                return
            }
            guard let empDoc = empSnap?.documents.first,
                  let businessRef = empDoc.reference.parent.parent else {
                print("Business not found for user \(self.currentUserId)")
                return
            }
            // 2) Fetch all employees under that business
            businessRef.collection("employees").getDocuments { snap, err in
                if let err = err {
                    print("Error fetching employees: \(err)")
                    return
                }
                let items = snap?.documents.compactMap { doc -> Employee? in
                    let data = doc.data()
                    let uid = doc.documentID
                    guard uid != self.currentUserId,
                          let name = data["name"] as? String,
                          let email = data["email"] as? String,
                          let phone = data["phone"] as? String,
                          let role = data["role"] as? String else {
                        return nil
                    }
                    return Employee(id: uid, name: name, email: email, phone: phone, role: role)
                } ?? []
                DispatchQueue.main.async {
                    self.employees = items
                }
            }
        }
    }
    
    /// Adds a new employee record under the current user's business
    func addEmployee(name: String, email: String, phone: String, role: String) {
        // 1) Find this user's business reference
        let empQuery = db.collectionGroup("employees")
            .whereField("userId", isEqualTo: currentUserId)
        empQuery.getDocuments { empSnap, empErr in
            if let empErr = empErr {
                print("Error finding current employee record: \(empErr)")
                return
            }
            guard let empDoc = empSnap?.documents.first,
                  let businessRef = empDoc.reference.parent.parent else {
                print("Business not found for user \(self.currentUserId)")
                return
            }
            // 2) Create a new employee document
            let newEmpRef = businessRef.collection("employees").document()
            let data: [String: Any] = [
                "userId": newEmpRef.documentID, // placeholder ID until linked to Auth
                "name": name,
                "email": email,
                "phone": phone,
                "role": role,
                "joinedAt": Timestamp()
            ]
            newEmpRef.setData(data) { error in
                if let error = error {
                    print("Error adding employee: \(error)")
                } else {
                    // Refresh list
                    DispatchQueue.main.async {
                        self.fetchEmployees()
                    }
                }
            }
        }
    }
}
