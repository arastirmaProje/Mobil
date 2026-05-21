//
//  PremiumSubscriptionRepositoryProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 14.05.2026.
//

import Foundation

protocol PremiumSubscriptionRepositoryProtocol {
    func fetchPlans() async throws -> [PremiumSubscriptionPlan]
    func subscribe(businessId: String) async throws
}
