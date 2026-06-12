import Foundation

@MainActor
final class ForgotPasswordViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var code: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var codeSent = false
    @Published var showResetPassword = false

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol = AuthRepositoryImpl(network: NetworkManager())) {
        self.authRepository = authRepository
    }

    // MARK: - SEND RESET CODE

    func sendCode() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            errorMessage = ConstantStrings.forgotPasswordEmailRequired
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await authRepository.forgotPassword(email: trimmedEmail)
            codeSent = true
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.sendResetFail
            )
        }
    }

    // MARK: - VERIFY RESET CODE

    func verifyCode() async {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedCode.count == 6 else {
            errorMessage = ConstantStrings.resetCodeLengthError
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let isValid = try await authRepository.verifyResetCode(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                code: trimmedCode
            )

            if isValid {
                showResetPassword = true
            } else {
                errorMessage = ConstantStrings.resetCodeInvalid
            }

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.resetCodeVerifyFailed
            )
        }
    }

    private func userMessage(
        from error: Error,
        fallback: String
    ) -> String {
        if case let RepositoryError.api(message) = error {
            return message
        }

        return fallback
    }
}
