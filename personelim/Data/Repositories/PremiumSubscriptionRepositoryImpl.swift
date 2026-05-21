//
//  PremiumSubscriptionRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 14.05.2026.
//

import Foundation

final class PremiumSubscriptionRepositoryImpl: PremiumSubscriptionRepositoryProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchPlans() async throws -> [PremiumSubscriptionPlan] {
        []
    }

    func subscribe(businessId: String) async throws {
        let response: ServiceResponse<Bool> = try await network.request(
            endpoint: .subscribeBusiness(businessId: businessId),
            method: .post,
            body: nil
        )

        guard response.success, response.data == true else {
            throw RepositoryError.api(
                message: response.message ?? ConstantStrings.premiumSubscribeFailed
            )
        }
    }
}
