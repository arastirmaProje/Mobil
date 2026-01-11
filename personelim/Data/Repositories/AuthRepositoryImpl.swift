//
//  AuthRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

extension String {
    static let empty = ""
}

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
               throw RepositoryError.api(message: response.message ?? ConstantStrings.failText)
           }

           return AuthUserEntity(
               userId: data.userId,
               email: data.email ?? .empty,
               fullName: data.fullName ?? "\(data.firstName ?? "") \(data.lastName ?? .empty)".trimmingCharacters(in: .whitespaces),
               token: data.token ?? .empty,
               expiresAt: data.expiresAt ?? .empty,
               role: data.role ?? .default
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
            throw RepositoryError.api(message: response.message ?? ConstantStrings.registerFail)
        }

        return AuthUserEntity(
            userId: data.userId,
            email: data.email ?? .empty,
            fullName: data.fullName ?? .empty,
            token: data.token ?? .empty,
            expiresAt: data.expiresAt ?? .empty,
            role: data.role ?? .default
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
            throw RepositoryError.api(message: response.message ?? ConstantStrings.sendResetFail)
        }

        return ForgotPasswordResponseEntity(
            email: data.email ?? .empty,
            expiresAt: data.expiresAt ?? .empty,
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

        throw RepositoryError.api(message: response.message ?? ConstantStrings.unknownError)
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
    
    // MARK: - PROFILE
    func getProfile() async throws -> UserProfileDTO {

        let response: UserProfileServiceResponseDTO = try await network.request(
            endpoint: .profile,
            method: .get,
            body: nil        
        )

        guard let data = response.data else {
            throw RepositoryError.api(message: response.message ?? ConstantStrings.profileNotRetrivied)
        }

        return data
    }


    func updateProfile(email: String, firstName: String, lastName: String, imageData: Data?) async throws -> UserProfileDTO {

        let fields: [String: String] = ["Email": email, "FirstName": firstName, "LastName": lastName]

        var files: [MultipartFile] = []
        if let imageData {
            files.append(
                MultipartFile(
                    fieldName: "Image",
                    fileName: "profile.jpg",
                    mimeType: "image/jpeg",
                    data: imageData
                )
            )
        }

        let response: UserProfileServiceResponseDTO = try await network.uploadMultipart(
            endpoint: .profileUpdate,
            method: .put,
            fields: fields,
            files: files
        )

        guard let data = response.data else {
            throw RepositoryError.api(message: response.message ?? ConstantStrings.profileUpdateFail)
        }

        return data
    }

    
        func deleteAccount() async throws {
            let res: ServiceResponse<Bool> = try await network.request(
                endpoint: .deleteAccount,
                method: .delete,
                body: nil
            )

            guard res.success else {
                throw RepositoryError.api(message: res.message ?? ConstantStrings.deleteAccountFail)
            }
        }
    


}

// MARK: - Repository Specific Error
enum RepositoryError: Error {
    case api(message: String)
}
