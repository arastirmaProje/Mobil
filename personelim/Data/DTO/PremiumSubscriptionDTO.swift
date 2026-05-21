//
//  PremiumSubscriptionPlanDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 14.05.2026.
//

import Foundation

struct PremiumSubscriptionPlanDTO: Decodable, Identifiable {
    let id: String
    let title: String?
    let name: String?
    let subtitle: String?
    let description: String?
    let price: Double?
    let priceText: String?
    let originalPrice: Double?
    let originalPriceText: String?
    let badgeText: String?
    let billingType: String?
    let type: String?
    let isHighlighted: Bool?

    func toEntity() -> PremiumSubscriptionPlan {
        let resolvedBillingType = PremiumBillingType(rawValue: (billingType ?? type ?? "").lowercased())
            ?? .monthly

        return PremiumSubscriptionPlan(
            id: id,
            title: title ?? name ?? ConstantStrings.premiumPlanFallbackTitle,
            subtitle: subtitle ?? description,
            priceText: priceText ?? formattedPrice(price),
            originalPriceText: originalPriceText ?? formattedPrice(originalPrice),
            badgeText: badgeText,
            billingType: resolvedBillingType,
            isHighlighted: isHighlighted ?? false
        )
    }

    private func formattedPrice(_ value: Double?) -> String {
        guard let value else { return ConstantStrings.dashPlaceholder }
        return String(format: "$%.2f", value).replacingOccurrences(of: ".", with: ",")
    }
}

struct PremiumPlansPayload: Decodable {
    let plans: [PremiumSubscriptionPlanDTO]

    init(from decoder: Decoder) throws {
        if let plans = try? [PremiumSubscriptionPlanDTO](from: decoder) {
            self.plans = plans
            return
        }

        let response = try ServiceResponse<[PremiumSubscriptionPlanDTO]>(from: decoder)
        self.plans = response.data ?? []
    }
}
