//
//  PremiumSubscriptionViewModelTests.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import XCTest
@testable import personelim

@MainActor
final class PremiumSubscriptionViewModelTests: XCTestCase {

    private var repository: MockPremiumSubscriptionRepository!
    private var vm: PremiumSubscriptionViewModel!

    override func setUp() {
        super.setUp()

        repository = MockPremiumSubscriptionRepository()

        vm = PremiumSubscriptionViewModel(
            repository: repository,
            useMockPlansWhenEmpty: true
        )
    }

    override func tearDown() {
        vm = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Load Plans

    func testLoadPlansSuccessUsesFetchedPlans() async {

        let plan = PremiumSubscriptionPlan(
            id: "monthly",
            title: "Monthly",
            subtitle: nil,
            priceText: "$9.99",
            originalPriceText: nil,
            badgeText: nil,
            billingType: .monthly,
            isHighlighted: false
        )

        repository.fetchPlansResult = .success([plan])

        await vm.loadPlans()

        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.plans.count, 1)
        XCTAssertEqual(vm.plans.first?.id, "monthly")
        XCTAssertEqual(repository.fetchPlansCallCount, 1)
    }

    func testLoadPlansEmptyUsesMockPlans() async {

        repository.fetchPlansResult = .success([])

        await vm.loadPlans()

        XCTAssertFalse(vm.plans.isEmpty)
        XCTAssertEqual(repository.fetchPlansCallCount, 1)
    }

    func testLoadPlansFailureWithMockEnabledUsesMockPlans() async {

        repository.fetchPlansResult = .failure(MockPremiumError.sample)

        await vm.loadPlans()

        XCTAssertFalse(vm.plans.isEmpty)
        XCTAssertNil(vm.errorMessage)
    }

    // MARK: - Select Plan

    func testSelectPlanSetsSelectedPlanAndShowsAlert() {

        let plan = PremiumSubscriptionPlan(
            id: "yearly",
            title: "Yearly",
            subtitle: nil,
            priceText: "$29.99",
            originalPriceText: nil,
            badgeText: nil,
            billingType: .yearly,
            isHighlighted: true
        )

        vm.selectPlan(plan)

        XCTAssertEqual(vm.selectedPlan?.id, "yearly")
        XCTAssertTrue(vm.isPurchaseAlertPresented)
    }

    // MARK: - Purchase

    func testPurchaseWithoutSelectedPlanReturnsFalse() async {

        let result = await vm.purchaseSelectedPlan(
            businessId: "business-1"
        )

        XCTAssertFalse(result)
        XCTAssertEqual(repository.subscribeCallCount, 0)
    }

    func testPurchaseSuccessSetsSuccessMessage() async {

        let plan = PremiumSubscriptionPlan(
            id: "monthly",
            title: "Monthly",
            subtitle: nil,
            priceText: "$9.99",
            originalPriceText: nil,
            badgeText: nil,
            billingType: .monthly,
            isHighlighted: false
        )

        vm.selectPlan(plan)

        let result = await vm.purchaseSelectedPlan(
            businessId: "business-1"
        )

        XCTAssertTrue(result)
        XCTAssertNil(vm.errorMessage)
        XCTAssertNotNil(vm.successMessage)

        XCTAssertEqual(repository.subscribeCallCount, 1)
        XCTAssertEqual(
            repository.receivedBusinessId,
            "business-1"
        )
    }

    func testPurchaseFailureSetsErrorMessage() async {

        repository.subscribeResult = .failure(
            MockPremiumError.sample
        )

        let plan = PremiumSubscriptionPlan(
            id: "monthly",
            title: "Monthly",
            subtitle: nil,
            priceText: "$9.99",
            originalPriceText: nil,
            badgeText: nil,
            billingType: .monthly,
            isHighlighted: false
        )

        vm.selectPlan(plan)

        let result = await vm.purchaseSelectedPlan(
            businessId: "business-1"
        )

        XCTAssertFalse(result)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertNil(vm.successMessage)

        XCTAssertEqual(repository.subscribeCallCount, 1)
    }
}

private enum MockPremiumError: LocalizedError {
    case sample

    var errorDescription: String? {
        "Premium test hatası"
    }
}
