//
//  SignupViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 07.12.2025.
//

import Foundation

@MainActor
final class SignupViewModel: ObservableObject {

    // MARK: - Form Inputs
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""

    // MARK: - UI State
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var goToVerifyEmail = false

    // EmailVerifyView’e gönderilecek email
    @Published private(set) var registeredEmail = ""

    // MARK: - Dependency
    private let registerUseCase: RegisterUserUseCaseProtocol

    init(registerUseCase: RegisterUserUseCaseProtocol = RegisterUserUseCase()) {
        self.registerUseCase = registerUseCase
    }

    // MARK: - ACTION
    func register() async {
        guard validateForm() else { return }

        isLoading = true
        showError = false

        let entity = RegisterUserEntity(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )

        do {
            let user = try await registerUseCase.execute(entity)

            registeredEmail = user.email
            goToVerifyEmail = true

        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    // MARK: - VALIDATION
    private func validateForm() -> Bool {
        if firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "Tüm alanlar gereklidir."
            showError = true
            return false
        }

        if !email.contains("@") {
            errorMessage = "Geçerli bir email giriniz."
            showError = true
            return false
        }

        if password.count < 6 {
            errorMessage = "Şifre en az 6 karakter olmalıdır."
            showError = true
            return false
        }

        return true
    }
}
