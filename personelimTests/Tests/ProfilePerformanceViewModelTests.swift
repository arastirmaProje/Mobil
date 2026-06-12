//
//  ProfilePerformanceViewModelTests.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import XCTest
@testable import personelim

@MainActor
final class ProfilePerformanceViewModelTests: XCTestCase {

    private var reportsUseCase: MockGetPerformanceReportsUseCase!
    private var vm: ProfilePerformanceViewModel!

    override func setUp() {
        super.setUp()

        reportsUseCase = MockGetPerformanceReportsUseCase()
        vm = ProfilePerformanceViewModel(
            getReportsUseCase: reportsUseCase
        )
    }

    override func tearDown() {
        vm = nil
        reportsUseCase = nil
        super.tearDown()
    }

    func testLoadSuccessSetsReports() async {
        reportsUseCase.result = .success([
            makeProfilePerformanceReport(
                id: "report-1",
                score: 85
            ),
            makeProfilePerformanceReport(
                id: "report-2",
                score: 70
            )
        ])

        await vm.load(
            businessId: "business-1",
            employeeUserId: "user-1"
        )

        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
        XCTAssertEqual(vm.reports.count, 2)
        XCTAssertEqual(vm.reports.first?.id, "report-1")
        XCTAssertEqual(vm.reports.first?.score, 85)
    }

    func testLoadFailureSetsError() async {
        reportsUseCase.result = .failure(ProfilePerformanceViewModelTestError.sample)

        await vm.load(
            businessId: "business-1",
            employeeUserId: "user-1"
        )

        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(
            vm.error,
            ProfilePerformanceViewModelTestError.sample.localizedDescription
        )
        XCTAssertTrue(vm.reports.isEmpty)
    }
}

private func makeProfilePerformanceReport(
    id: String,
    score: Int
) -> PerformanceReportDTO {
    let json = """
    {
        "id": "\(id)",
        "businessId": "business-1",
        "employeeUserId": "user-1",
        "createdByName": "Test User",
        "startDate": "2026-01-01",
        "endDate": "2026-01-31",
        "score": \(score),
        "summaryText": "Özet",
        "detailText": "Detay"
    }
    """

    let data = Data(json.utf8)
    return try! JSONDecoder().decode(PerformanceReportDTO.self, from: data)
}

private enum ProfilePerformanceViewModelTestError: LocalizedError {
    case sample

    var errorDescription: String? {
        "Test hatası"
    }
}
