import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let loginUseCase: LoginUseCaseProtocol

    init(loginUseCase: LoginUseCaseProtocol = LoginUseCase()) {
        self.loginUseCase = loginUseCase
    }

    func login(appState: AppState) async {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = ConstantStrings.loginRequiredFieldsError
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await loginUseCase.execute(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )

            TokenStore.shared.save(
                user.token,
                rememberMe: rememberMe
            )

            if rememberMe {
                UserDefaults.standard.set(user.fullName, forKey: "full_name")
                UserDefaults.standard.set(user.email, forKey: "user_email")
                UserDefaults.standard.set(user.userId, forKey: "user_id")
            } else {
                UserDefaults.standard.removeObject(forKey: "full_name")
                UserDefaults.standard.removeObject(forKey: "user_email")
                UserDefaults.standard.removeObject(forKey: "user_id")
            }

            let dto = UserProfileDTO(
                id: user.userId,
                email: user.email,
                firstName: nil,
                lastName: nil,
                fullName: user.fullName,
                phoneNumber: nil,
                createdAt: nil,
                lastLoginAt: nil,
                businessCount: nil,
                ownedBusinessCount: nil,
                imageUrl: nil
            )

            appState.applyLogin(
                userDTO: dto,
                role: user.role
            )

            Task { @MainActor in
                await appState.bootstrap(
                    authRepository: AuthRepositoryImpl(network: NetworkManager()),
                    businessRepository: BusinessRepositoryImpl(networkManager: NetworkManager()),
                    businessMemberRepository: BusinessMemberRepositoryImpl(network: NetworkManager())
                )
            }

        } catch {
            errorMessage = userMessage(from: error)
        }
    }

    private func userMessage(from error: Error) -> String {
        if case let RepositoryError.api(message) = error {
            return message
        }

        return ConstantStrings.failText
    }
}
