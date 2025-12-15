//
//  SignupViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 07.12.2025.
//

import Foundation

@MainActor
final class SignupViewModel: ObservableObject {

    // MARK: - Inputs
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""

    // MARK: - UI State
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    // MARK: - Navigation
    @Published var goToCreateCompany = false

    // MARK: - Dependencies
    private let registerUseCase: RegisterUserUseCaseProtocol

    init(registerUseCase: RegisterUserUseCaseProtocol = RegisterUserUseCase()) {
        self.registerUseCase = registerUseCase
    }
    // MARK: - Actions
    func register() async {
        guard validateForm() else { return }

        isLoading = true
        showError = false

        do {
            let authUser = try await registerUseCase.execute(
                RegisterUserEntity( firstName: firstName, lastName: lastName, email: email, password: password))
            TokenStore.shared.save(authUser.token)
            goToCreateCompany = true

        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

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
