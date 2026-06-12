//
//  PersonnelDetailViewModelTests.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import XCTest
@testable import personelim

@MainActor
final class PersonnelDetailViewModelTests: XCTestCase {

    private var memberUseCase: MockGetBusinessMemberUseCase!
    private var reportsUseCase: MockGetPerformanceReportsUseCase!
    private var vm: PersonnelDetailViewModel!

    override func setUp() {
        super.setUp()

        memberUseCase = MockGetBusinessMemberUseCase()
        reportsUseCase = MockGetPerformanceReportsUseCase()

        vm = PersonnelDetailViewModel(
            getMemberUseCase: memberUseCase,
            getReportsUseCase: reportsUseCase
        )
    }

    override func tearDown() {
        vm = nil
        memberUseCase = nil
        reportsUseCase = nil
        super.tearDown()
    }

    func test_load_success_setsMember() async {

        let member = BusinessMemberDTO(
            id: "1",
            userId: "user1",
            fullName: "Yusuf Kaan Usta",
            email: "test@test.com",
            departmentId: nil,
            positionId: nil,
            phoneNumber: nil,
            role: .employee,
            positionName: nil,
            salary: nil,
            tcIdentityNumber: nil,
            position: nil,
            joinedAt: nil,
            isActive: true,
            documents: nil
        )

        memberUseCase.result = .success(member)

        await vm.load(memberId: "1")

        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.member?.id, "1")
        XCTAssertFalse(vm.isLoading)
    }

    func test_load_failure_setsErrorMessage() async {

        memberUseCase.result = .failure(MockError.sample)

        await vm.load(memberId: "1")

        XCTAssertNil(vm.member)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    func test_loadReports_success_setsReports() async {

        let report = makeReport()

        reportsUseCase.result = .success([report])

        await vm.loadReports(
            businessId: "business",
            employeeUserId: "user"
        )

        XCTAssertNil(vm.reportsError)
        XCTAssertEqual(vm.reports.count, 1)
        XCTAssertFalse(vm.isReportsLoading)
    }

    func test_loadReports_failure_setsReportsError() async {

        reportsUseCase.result = .failure(MockError.sample)

        await vm.loadReports(
            businessId: "business",
            employeeUserId: "user"
        )

        XCTAssertTrue(vm.reports.isEmpty)
        XCTAssertNotNil(vm.reportsError)
        XCTAssertFalse(vm.isReportsLoading)
    }
    
    private func makeReport() -> PerformanceReportDTO {
        let json = """
        {
            "id": "report-1",
            "businessId": "business",
            "employeeUserId": "user",
            "createdByName": "Yusuf",
            "startDate": "2026-01-01",
            "endDate": "2026-01-31",
            "score": 85,
            "summaryText": "Özet",
            "detailText": "Detay"
        }
        """

        let data = Data(json.utf8)
        return try! JSONDecoder().decode(PerformanceReportDTO.self, from: data)
    }
}
