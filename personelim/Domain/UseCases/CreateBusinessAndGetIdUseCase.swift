//
//  CreateBusinessAndGetIdUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

protocol CreateBusinessAndGetIdUseCaseProtocol {
    func execute(request: CreateBusinessRequestDTO) async throws -> String
}

final class CreateBusinessAndGetIdUseCase: CreateBusinessAndGetIdUseCaseProtocol {

    private let repository: BusinessRepositoryProtocol

    init(repository: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager())) {
        self.repository = repository
    }

    func execute(request: CreateBusinessRequestDTO) async throws -> String {
        try await repository.createBusinessAndReturnId(request: request)
    }
}
