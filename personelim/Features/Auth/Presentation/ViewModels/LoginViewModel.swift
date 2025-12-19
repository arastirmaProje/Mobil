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
    @Published var isLoggedIn: Bool = false

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

    
            UserDefaults.standard.set(user.token, forKey: "auth_token")
            UserDefaults.standard.set(user.fullName, forKey: "full_name")
            UserDefaults.standard.set(user.email, forKey: "user_email")
            UserDefaults.standard.set(user.userId, forKey: "user_id")
            UserDefaults.standard.set(user.expiresAt, forKey: "token_expires_at")

            if rememberMe {
                UserDefaults.standard.set(email, forKey: "remember_email")
            } else {
                UserDefaults.standard.removeObject(forKey: "remember_email")
            }


            appState.applyLogin(userId: user.userId, role: user.role)

            isLoggedIn = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
