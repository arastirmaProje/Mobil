//
//  GetBusinessProfileUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 14.12.2025.
//
/*
import Foundation

protocol GetBusinessProfileUseCaseProtocol {
    func execute(businessId: String) async throws -> BusinessProfileEntity
}

final class GetBusinessProfileUseCase: GetBusinessProfileUseCaseProtocol {

    private let repository: BusinessRepositoryProtocol

    init(repository: BusinessRepositoryProtocol = BusinessRepositoryImpl(
        network: NetworkManager()
    )) {
        self.repository = repository
    }

    func execute(businessId: String) async throws -> BusinessProfileEntity {
        try await repository.getBusiness(businessId: businessId)
    }
}

*/
