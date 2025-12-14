//
//  ForgotPasswordUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 7.12.2025.
//

struct ForgotPasswordUseCase {

    let repository: AuthRepositoryProtocol

    func execute(email: String) async throws -> ForgotPasswordResponseEntity {
        try await repository.forgotPassword(email: email)
    }
}
