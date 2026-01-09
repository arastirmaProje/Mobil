//
//  LoginViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 06.12.2025.
//
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let loginUseCase: LoginUseCaseProtocol

    init(loginUseCase: LoginUseCaseProtocol = LoginUseCase()) {
        self.loginUseCase = loginUseCase
    }

    func login(appState: AppState) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email ve şifre zorunludur."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await loginUseCase.execute(email: email, password: password)

            TokenStore.shared.save(user.token)

            UserDefaults.standard.set(user.fullName, forKey: "full_name")
            UserDefaults.standard.set(user.email, forKey: "user_email")
            UserDefaults.standard.set(user.userId, forKey: "user_id")

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
            errorMessage = error.localizedDescription
        }
    }

}
