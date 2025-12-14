//
//  ResetPasswordViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

@MainActor
final class ResetPasswordViewModel: ObservableObject {

    // MARK: - Inputs
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""

    // MARK: - States
    @Published var isLoading = false
    @Published var success = false

    @Published var errorMessage: String = ""
    @Published var showError = false

    private let email: String
    private let code: String

    private let resetPasswordUseCase: ResetPasswordUseCaseProtocol

    init(
        email: String,
        code: String,
        resetPasswordUseCase: ResetPasswordUseCaseProtocol =
            ResetPasswordUseCase(repository: AuthRepositoryImpl(network: NetworkManager()))
    ) {
        self.email = email
        self.code = code
        self.resetPasswordUseCase = resetPasswordUseCase
    }

    // MARK: - RESET PASSWORD
    func resetPassword() async {

        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Şifre alanları boş olamaz."
            showError = true
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Şifreler eşleşmiyor."
            showError = true
            return
        }

        isLoading = true

        do {
            let result = try await resetPasswordUseCase.execute(
                email: email,
                code: code,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )

            if result {
                success = true
            }

        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }
}
