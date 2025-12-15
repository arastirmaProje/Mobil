//
//  VerifyBusinessUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

final class VerifyBusinessUseCase: VerifyBusinessUseCaseProtocol {

    private let repository: BusinessRepositoryProtocol

    init(
        repository: BusinessRepositoryProtocol = BusinessRepositoryImpl(
            networkManager: NetworkManager()
        )
    ) {
        self.repository = repository
    }

    func execute(code: String) async throws -> Bool {
        let response = try await repository.verifyBusiness(code: code)
        return response.data
    }
}
