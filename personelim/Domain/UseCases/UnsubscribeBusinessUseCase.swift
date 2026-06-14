//
//  UnsubscribeBusinessUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 14.06.2026.
//

import Foundation

protocol UnsubscribeBusinessUseCaseProtocol {
    func execute(businessId: String) async throws
}

final class UnsubscribeBusinessUseCase: UnsubscribeBusinessUseCaseProtocol {

    private let repository: BusinessRepositoryProtocol

    init(repository: BusinessRepositoryProtocol) {
        self.repository = repository
    }

    func execute(businessId: String) async throws {
        try await repository.unsubscribeBusiness(
            businessId: businessId
        )
    }
}
