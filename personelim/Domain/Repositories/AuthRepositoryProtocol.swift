//
//  AuthRepositoryProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

protocol AuthRepositoryProtocol {
    func register(_ user: RegisterUserEntity) async throws -> AuthUserEntity
    func login(email: String, password: String) async throws -> AuthUserEntity
    func forgotPassword(email: String) async throws -> ForgotPasswordResponseEntity
    func verifyResetCode(email: String, code: String) async throws -> Bool
    func resetPassword(email: String, code: String, newPassword: String, confirmPassword: String) async throws -> Bool
}
