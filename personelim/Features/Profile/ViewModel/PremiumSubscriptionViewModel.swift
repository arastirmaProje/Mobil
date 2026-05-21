//
//  PremiumSubscriptionViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 14.05.2026.
//

import Foundation

@MainActor
final class PremiumSubscriptionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var plans: [PremiumSubscriptionPlan] = []
    @Published var selectedPlan: PremiumSubscriptionPlan?
    @Published var isPurchaseAlertPresented = false
    @Published var isPurchasing = false
    @Published var successMessage: String?

    private let getPlansUseCase: GetPremiumPlansUseCaseProtocol
    private let subscribeUseCase: SubscribePremiumUseCaseProtocol
    private let useMockPlansWhenEmpty: Bool

    init(
        repository: PremiumSubscriptionRepositoryProtocol = PremiumSubscriptionRepositoryImpl(),
        useMockPlansWhenEmpty: Bool = true
    ) {
        self.getPlansUseCase = GetPremiumPlansUseCase(repository: repository)
        self.subscribeUseCase = SubscribePremiumUseCase(repository: repository)
        self.useMockPlansWhenEmpty = useMockPlansWhenEmpty
    }

    func loadPlans() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetchedPlans = try await getPlansUseCase.execute()
            plans = fetchedPlans.isEmpty && useMockPlansWhenEmpty
                ? Self.mockPlans
                : fetchedPlans
        } catch {
            if useMockPlansWhenEmpty {
                plans = Self.mockPlans
            } else {
                errorMessage = userMessage(from: error)
            }
        }
    }

    func selectPlan(_ plan: PremiumSubscriptionPlan) {
        selectedPlan = plan
        isPurchaseAlertPresented = true
    }

    func purchaseSelectedPlan(businessId: String) async -> Bool {
        guard selectedPlan != nil else { return false }

        isPurchasing = true
        errorMessage = nil
        successMessage = nil
        defer { isPurchasing = false }

        do {
            try await subscribeUseCase.execute(businessId: businessId)
            successMessage = ConstantStrings.premiumSubscribeSuccess
            return true
        } catch {
            errorMessage = userMessage(from: error)
            return false
        }
    }

    private func userMessage(from error: Error) -> String {
        if case let RepositoryError.api(message) = error {
            return message
        }
        return error.localizedDescription
    }

    private static let mockPlans: [PremiumSubscriptionPlan] = [
        PremiumSubscriptionPlan(
            id: "yearly",
            title: ConstantStrings.premiumPlanYearly,
            subtitle: ConstantStrings.premiumPlanAllFeatures,
            priceText: "$29,99",
            originalPriceText: "$49,99",
            badgeText: ConstantStrings.premiumMockBadge,
            billingType: .yearly,
            isHighlighted: true
        ),
        PremiumSubscriptionPlan(
            id: "monthly",
            title: ConstantStrings.premiumPlanMonthly,
            subtitle: nil,
            priceText: "$6,99",
            originalPriceText: nil,
            badgeText: nil,
            billingType: .monthly,
            isHighlighted: false
        ),
        PremiumSubscriptionPlan(
            id: "lifetime",
            title: ConstantStrings.premiumPlanLifetime,
            subtitle: ConstantStrings.premiumPlanLifetimeSubtitle,
            priceText: "$139,99",
            originalPriceText: nil,
            badgeText: nil,
            billingType: .lifetime,
            isHighlighted: false
        )
    ]
}
