//
//  VerifyResetCodeUseCase .swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

protocol VerifyResetCodeUseCaseProtocol {
    func execute(email: String, code: String) async throws -> Bool
}

final class VerifyResetCodeUseCase: VerifyResetCodeUseCaseProtocol {

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, code: String) async throws -> Bool {
        return try await repository.verifyResetCode(email: email, code: code)
    }
}
