//
//  PremiumSubscriptionPlan.swift
//  personelim
//
//  Created by Tuğberk Acabey on 14.05.2026.
//

import Foundation

enum PremiumBillingType: String, Decodable, Hashable {
    case yearly
    case monthly
    case lifetime
}

struct PremiumSubscriptionPlan: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let priceText: String
    let originalPriceText: String?
    let badgeText: String?
    let billingType: PremiumBillingType
    let isHighlighted: Bool
}
