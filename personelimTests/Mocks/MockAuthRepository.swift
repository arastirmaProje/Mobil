//
//  MockAuthRepository.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

@testable import personelim
import XCTest

final class MockAuthRepository: AuthRepositoryProtocol {

    // MARK: - Test kontrol değişkenleri
    var forgotPasswordResult: Result<ForgotPasswordResponseEntity, Error>!
    var verifyResetCodeResult: Result<Bool, Error>!

    // MARK: - Forgot Password
    func forgotPassword(email: String) async throws -> ForgotPasswordResponseEntity {
        try forgotPasswordResult.get()
    }

    func verifyResetCode(email: String, code: String) async throws -> Bool {
        try verifyResetCodeResult.get()
    }

    // MARK: - ZORUNLU AMA BU TESTTE KULLANILMIYOR
    func register(_ user: RegisterUserEntity) async throws -> AuthUserEntity {
        fatalError("register not needed in ForgotPassword tests")
    }

    func login(email: String, password: String) async throws -> AuthUserEntity {
        fatalError("login not needed in ForgotPassword tests")
    }

    func resetPassword(
        email: String,
        code: String,
        newPassword: String,
        confirmPassword: String
    ) async throws -> Bool {
        fatalError("resetPassword not needed in ForgotPassword tests")
    }

    func getProfile() async throws -> UserProfileDTO {
        fatalError("getProfile not needed in ForgotPassword tests")
    }

    func updateProfile(
        email: String,
        firstName: String,
        lastName: String,
        imageData: Data?
    ) async throws -> UserProfileDTO {
        fatalError("updateProfile not needed in ForgotPassword tests")
    }

    func deleteAccount() async throws {
        fatalError("deleteAccount not needed in ForgotPassword tests")
    }
}
