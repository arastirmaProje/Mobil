import Foundation

@MainActor
final class SignupViewModel: ObservableObject {

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""

    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    @Published var goToCreateCompany = false
    @Published var createdUser: AuthUserEntity?

    private let registerUseCase: RegisterUserUseCaseProtocol

    init(registerUseCase: RegisterUserUseCaseProtocol = RegisterUserUseCase()) {
        self.registerUseCase = registerUseCase
    }

    func register() async {
        guard validateForm() else { return }

        isLoading = true
        showError = false
        errorMessage = ""

        defer { isLoading = false }

        do {
            let authUser = try await registerUseCase.execute(
                RegisterUserEntity(
                    firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                    lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
            )

            TokenStore.shared.save(
                authUser.token,
                rememberMe: false
            )

            createdUser = authUser
            goToCreateCompany = true

        } catch {
            errorMessage = userMessage(from: error)
            showError = true
        }
    }

    private func validateForm() -> Bool {

        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            errorMessage = ConstantStrings.signupRequiredFieldsError
            showError = true
            return false
        }

        if !email.contains("@") {
            errorMessage = ConstantStrings.signupInvalidEmailError
            showError = true
            return false
        }

        if password.count < 6 {
            errorMessage = ConstantStrings.signupPasswordMinLengthError
            showError = true
            return false
        }

        return true
    }

    private func userMessage(from error: Error) -> String {
        if case let RepositoryError.api(message) = error {
            return message
        }

        return ConstantStrings.failText
    }
}
