//
//  CreateBusinessUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

protocol CreateBusinessUseCaseProtocol {
    func execute(request: CreateBusinessRequestDTO) async throws
}

final class CreateBusinessUseCase: CreateBusinessUseCaseProtocol {

    private let repository: BusinessRepositoryProtocol

    init(repository: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager())) {
        self.repository = repository
    }

    func execute(request: CreateBusinessRequestDTO) async throws {
        try await repository.createBusiness(request: request)
    }
}
