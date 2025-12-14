//
//  AuthRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryProtocol {

    // MARK: - Dependencies
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    // MARK: - LOGIN
    func login(email: String, password: String) async throws -> AuthUserEntity {

        let body = LoginRequestDTO(email: email, password: password)

        let response: AuthResponseServiceDTO = try await network.request(
            endpoint: .login,
            method: .post,
            body: body
        )

        guard let data = response.data else {
            throw RepositoryError.api(message: response.message ?? "Login failed")
        }

        return AuthUserEntity(
            userId: data.userId,
            email: data.email ?? "",
            fullName: data.fullName ?? "",
            token: data.token ?? "",
            expiresAt: data.expiresAt
        )
    }

    // MARK: - REGISTER
    func register(_ user: RegisterUserEntity) async throws -> AuthUserEntity {

        let body = RegisterRequestDTO(
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            password: user.password
        )

        let response: AuthResponseServiceDTO = try await network.request(
            endpoint: .register,
            method: .post,
            body: body
        )

        guard let data = response.data else {
            throw RepositoryError.api(message: response.message ?? "Register failed")
        }

        return AuthUserEntity(
            userId: data.userId,
            email: data.email ?? "",
            fullName: data.fullName ?? "",
            token: data.token ?? "",
            expiresAt: data.expiresAt
        )
    }

    // MARK: - FORGOT PASSWORD
    func forgotPassword(email: String) async throws -> ForgotPasswordResponseEntity {

        let body = ForgotPasswordRequestDTO(email: email)

        let response: ForgotPasswordServiceResponseDTO = try await network.request(
            endpoint: .forgotPassword,
            method: .post,
            body: body
        )

        guard let data = response.data else {
            throw RepositoryError.api(message: response.message ?? "Failed to send reset code")
        }

        return ForgotPasswordResponseEntity(
            email: data.email ?? "",
            expiresAt: data.expiresAt ?? "",
            expiresInMinutes: data.expiresInMinutes ?? 0
        )
    }
    
    // MARK: - VERIFY RESET CODE
    func verifyResetCode(email: String, code: String) async throws -> Bool {

        let body = VerifyResetCodeRequestDTO(email: email, code: code)

        let response: VerifyResetCodeResponseDTO = try await network.request(
            endpoint: .verifyResetCode,
            method: .post,
            body: body
        )

        if response.success {
            return response.data ?? false
        }

        throw RepositoryError.api(message: response.message ?? "Unknown error")
    }
    
    // MARK: - RESET PASSWORD
    func resetPassword(email: String,
                       code: String,
                       newPassword: String,
                       confirmPassword: String) async throws -> Bool {

        let body = ResetPasswordRequestDTO(
            email: email,
            code: code,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )

        let response: VerifyResetCodeResponseDTO = try await network.request(
            endpoint: .resetPassword,
            method: .post,
            body: body
        )

        return response.success
    }
}

// MARK: - Repository Specific Error
enum RepositoryError: Error {
    case api(message: String)
}
