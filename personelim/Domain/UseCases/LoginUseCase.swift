//
//  LoginUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> AuthUserEntity
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let repo: AuthRepositoryProtocol

    init(repo: AuthRepositoryProtocol = AuthRepositoryImpl(network: NetworkManager())) {
        self.repo = repo
    }

    func execute(email: String, password: String) async throws -> AuthUserEntity {
        try await repo.login(email: email, password: password)
    }
}
