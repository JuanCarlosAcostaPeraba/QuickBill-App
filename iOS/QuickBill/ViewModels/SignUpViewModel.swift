//
//  SignUpViewModel.swift
//  QuickBill
//
//  Created by Juan Carlos Acosta Perabá on 27/4/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class SignUpViewModel: ObservableObject {
    @Published var step: Int = 1

    // Phase 1
    @Published var email: String = ""
    @Published var password: String = ""

    // Phase 2
    @Published var fullName: String = ""
    @Published var phone: String = ""
    @Published var rememberMe: Bool = false

    // Phase 3
    @Published var companyName: String = ""
    @Published var tagline: String = ""
    @Published var taxId: String = ""
    @Published var companyEmail: String = ""
    @Published var companyPhone: String = ""

    // Phase 4
    @Published var address: String = ""
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var postcode: String = ""

    // Alert and navigation
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = "Error"
    @Published var alertMessage: String = ""
    @Published var navigateToHome: Bool = false

    private let db = Firestore.firestore()

    // Validation for each phase
    var canProceed: Bool {
        switch step {
        case 1:
            return email.contains("@") && email.contains(".") && password.count >= 6
        case 2:
            return !fullName.isEmpty && !phone.isEmpty
        case 3:
            return !companyName.isEmpty && !taxId.isEmpty && companyEmail.contains("@")
        case 4:
            return !address.isEmpty && !city.isEmpty && !country.isEmpty && !postcode.isEmpty
        default:
            return false
        }
    }

    // Move to next phase or register
    func nextStep() {
        guard canProceed else {
            alertMessage = "Please fill all fields correctly."
            showAlert = true
            return
        }
        if step < 4 {
            step += 1
        } else {
            registerBusiness()
        }
    }

    // Move to previous phase
    func previousStep() {
        if step > 1 {
            step -= 1
        }
    }

    // Cancel signup (pop or dismiss)
    func cancel() {
        // Implement dismissal logic in the view (e.g. pop)
    }

    // Reset all fields
    func reset() {
        step = 1
        email = ""
        password = ""
        fullName = ""
        phone = ""
        rememberMe = false
        companyName = ""
        tagline = ""
        taxId = ""
        companyEmail = ""
        companyPhone = ""
        address = ""
        city = ""
        country = ""
        postcode = ""
        showAlert = false
        alertMessage = ""
        navigateToHome = false
    }

    // Register user in Firebase Auth and create Firestore documents
    private func registerBusiness() {
        Task {
            do {
                // Create Firebase Auth user
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                let user = authResult.user

                // Create business document
                let businessRef = db.collection("businesses").document()
                let businessData: [String: Any] = [
                    "name": companyName,
                    "tagline": tagline,
                    "address": address,
                    "city": city,
                    "country": country,
                    "postcode": postcode,
                    "taxId": taxId,
                    "email": companyEmail,
                    "phone": companyPhone,
                    "createdAt": Timestamp(),
                    "subscriptionPlan": "free",
                    "storageLimit": "1 month"
                ]
                try await businessRef.setData(businessData)

                // Create admin employee
                let employeeData: [String: Any] = [
                    "userId": user.uid,
                    "name": fullName,
                    "email": email,
                    "phone": phone,
                    "role": "admin",
                    "joinedAt": Timestamp()
                ]
                try await businessRef.collection("employees").document(user.uid).setData(employeeData)

                // Navigate to home screen
                DispatchQueue.main.async {
                    self.navigateToHome = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}
