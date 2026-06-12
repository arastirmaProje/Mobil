//
//  MockPremiumSubscriptionRepository.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import Foundation
@testable import personelim

final class MockPremiumSubscriptionRepository:
    PremiumSubscriptionRepositoryProtocol {

    var fetchPlansResult:
        Result<[PremiumSubscriptionPlan], Error> = .success([])

    var subscribeResult:
        Result<Void, Error> = .success(())

    private(set) var fetchPlansCallCount = 0

    private(set) var subscribeCallCount = 0
    private(set) var receivedBusinessId: String?

    func fetchPlans() async throws -> [PremiumSubscriptionPlan] {
        fetchPlansCallCount += 1
        return try fetchPlansResult.get()
    }

    func subscribe(businessId: String) async throws {
        subscribeCallCount += 1
        receivedBusinessId = businessId

        _ = try subscribeResult.get()
    }
}
