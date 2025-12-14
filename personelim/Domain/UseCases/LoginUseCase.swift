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

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthRepositoryImpl(network: NetworkManager())) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws -> AuthUserEntity {
        try await repository.login(email: email, password: password)
    }
}
