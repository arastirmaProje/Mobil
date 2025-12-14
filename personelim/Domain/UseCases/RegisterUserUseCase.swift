//
//  RegisterUserUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

protocol RegisterUserUseCaseProtocol {
    func execute(_ user: RegisterUserEntity) async throws -> AuthUserEntity
}

final class RegisterUserUseCase: RegisterUserUseCaseProtocol {

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthRepositoryImpl(network: NetworkManager())) {
        self.repository = repository
    }

    func execute(_ user: RegisterUserEntity) async throws -> AuthUserEntity {
        try await repository.register(user)
    }
}
