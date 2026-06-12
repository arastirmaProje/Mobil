import Foundation

@MainActor
final class ResetPasswordViewModel: ObservableObject {

    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""

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
            ResetPasswordUseCase(
                repository: AuthRepositoryImpl(
                    network: NetworkManager()
                )
            )
    ) {
        self.email = email
        self.code = code
        self.resetPasswordUseCase = resetPasswordUseCase
    }

    // MARK: - RESET PASSWORD

    func resetPassword() async {

        let password = newPassword.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let confirm = confirmPassword.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !password.isEmpty,
              !confirm.isEmpty else {

            errorMessage = ConstantStrings.resetPasswordFieldsRequired
            showError = true
            return
        }

        guard password == confirm else {

            errorMessage = ConstantStrings.resetPasswordMismatch
            showError = true
            return
        }

        isLoading = true
        errorMessage = ""
        showError = false

        defer { isLoading = false }

        do {
            let result = try await resetPasswordUseCase.execute(
                email: email,
                code: code,
                newPassword: password,
                confirmPassword: confirm
            )

            if result {
                success = true
            } else {
                errorMessage = ConstantStrings.resetPasswordFailed
                showError = true
            }

        } catch {
            errorMessage = userMessage(from: error)
            showError = true
        }
    }

    private func userMessage(from error: Error) -> String {

        if case let RepositoryError.api(message) = error {
            return message
        }

        return ConstantStrings.resetPasswordFailed
    }
}
