//
//  PerformanceQueryViewModelTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

@MainActor
final class PerformanceQueryViewModelTests: XCTestCase {

    private var useCase: MockQueryPerformanceUseCase!
    private var vm: PerformanceQueryViewModel!

    override func setUp() {
        super.setUp()
        useCase = MockQueryPerformanceUseCase()
        vm = PerformanceQueryViewModel(queryUseCase: useCase)
    }

    override func tearDown() {
        vm = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: - Success

    func test_submit_success_returnsReport() async {
        let report = PerformanceReportDTO.mock()
        useCase.result = .success(report)

        let result = await vm.submit(
            businessId: "biz_1",
            employeeUserId: "user_1"
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(useCase.receivedBody?.businessId, "biz_1")
        XCTAssertEqual(useCase.receivedBody?.employeeUserId, "user_1")
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Date Order Fix

    func test_submit_swapsDates_whenStartDateAfterEndDate() async {
        vm.startDate = Date()
        vm.endDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!

        useCase.result = .success(.mock())

        _ = await vm.submit(
            businessId: "biz_1",
            employeeUserId: "user_1"
        )

        let body = useCase.receivedBody!
        XCTAssertLessThanOrEqual(body.startDate, body.endDate)
    }

    // MARK: - Error

    func test_submit_failure_setsErrorMessage() async {
        useCase.result = .failure(NSError(domain: "test", code: 1))

        let result = await vm.submit(
            businessId: "biz_1",
            employeeUserId: "user_1"
        )

        XCTAssertNil(result)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }
}
