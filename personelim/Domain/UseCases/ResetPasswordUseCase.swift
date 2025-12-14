//
//  ResetPasswordUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 7.12.2025.
//

import Foundation

protocol ResetPasswordUseCaseProtocol {
    func execute(email: String,
                 code: String,
                 newPassword: String,
                 confirmPassword: String) async throws -> Bool
}

final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String,
                 code: String,
                 newPassword: String,
                 confirmPassword: String) async throws -> Bool {

        try await repository.resetPassword(
            email: email,
            code: code,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )
    }
}
