//
//  PremiumSubscriptionUseCases.swift
//  personelim
//
//  Created by Tuğberk Acabey on 14.05.2026.
//

import Foundation

protocol GetPremiumPlansUseCaseProtocol {
    func execute() async throws -> [PremiumSubscriptionPlan]
}

final class GetPremiumPlansUseCase: GetPremiumPlansUseCaseProtocol {
    private let repository: PremiumSubscriptionRepositoryProtocol

    init(repository: PremiumSubscriptionRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [PremiumSubscriptionPlan] {
        try await repository.fetchPlans()
    }
}

protocol SubscribePremiumUseCaseProtocol {
    func execute(businessId: String) async throws
}

final class SubscribePremiumUseCase: SubscribePremiumUseCaseProtocol {
    private let repository: PremiumSubscriptionRepositoryProtocol

    init(repository: PremiumSubscriptionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(businessId: String) async throws {
        try await repository.subscribe(businessId: businessId)
    }
}
