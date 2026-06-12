import XCTest
@testable import personelim

@MainActor
final class PersonnelListViewModelTests: XCTestCase {

    private var useCase: MockQueryBulkPerformanceScoresUseCase!
    private var vm: PersonnelListViewModel!

    override func setUp() {
        super.setUp()
        useCase = MockQueryBulkPerformanceScoresUseCase()
        vm = PersonnelListViewModel(bulkUseCase: useCase)
    }

    override func tearDown() {
        vm = nil
        useCase = nil
        super.tearDown()
    }

    func testFilteredWhenQueryEmptyReturnsAllMembers() {
        let members = [
            makeMember(id: "m1", userId: "u1", fullName: "Ali Veli", email: "ali@test.com"),
            makeMember(id: "m2", userId: "u2", fullName: "Ayşe Kaya", email: "ayse@test.com")
        ]

        vm.query = ""

        XCTAssertEqual(vm.filtered(members).count, 2)
    }

    func testFilteredWhenQueryWhitespaceReturnsAllMembers() {
        let members = [
            makeMember(id: "m1", userId: "u1", fullName: "Ali Veli", email: "ali@test.com")
        ]

        vm.query = "   "

        XCTAssertEqual(vm.filtered(members).count, 1)
    }

    func testFilteredByFullNameReturnsMatchingMember() {
        let members = [
            makeMember(id: "m1", userId: "u1", fullName: "Ali Veli", email: "ali@test.com"),
            makeMember(id: "m2", userId: "u2", fullName: "Ayşe Kaya", email: "ayse@test.com")
        ]

        vm.query = "ayşe"

        let result = vm.filtered(members)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.fullName, "Ayşe Kaya")
    }

    func testFilteredByEmailReturnsMatchingMember() {
        let members = [
            makeMember(id: "m1", userId: "u1", fullName: "Ali Veli", email: "ali@test.com"),
            makeMember(id: "m2", userId: "u2", fullName: "Ayşe Kaya", email: "ayse@test.com")
        ]

        vm.query = "ali@test"

        let result = vm.filtered(members)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.email, "ali@test.com")
    }

    func testRunBulkQuerySuccessStoresScoresByAllKeys() async {
        useCase.result = .success([
            makeBulkScore(
                employeeUserId: "USER-1",
                calisanId: "MEMBER-1",
                performanceScore: 87,
                fullName: "Ali Veli"
            )
        ])

        let result = await vm.runBulkQuery(
            businessId: "business-1",
            start: Date(),
            end: Date()
        )

        XCTAssertTrue(result)
        XCTAssertNil(vm.bulkError)
        XCTAssertFalse(vm.isBulkLoading)

        XCTAssertEqual(vm.bulkScoresByUserId["user-1"], 87)
        XCTAssertEqual(vm.bulkScoresByUserId["member-1"], 87)
        XCTAssertEqual(vm.bulkScoresByUserId["name:ali veli"], 87)
    }

    func testRunBulkQueryIgnoresItemsWithNilScore() async {
        useCase.result = .success([
            makeBulkScore(
                employeeUserId: "user-1",
                calisanId: "member-1",
                performanceScore: nil,
                fullName: "Ali Veli"
            )
        ])

        let result = await vm.runBulkQuery(
            businessId: "business-1",
            start: Date(),
            end: Date()
        )

        XCTAssertTrue(result)
        XCTAssertTrue(vm.bulkScoresByUserId.isEmpty)
    }

    func testRunBulkQueryFailureSetsBulkError() async {
        useCase.result = .failure(PersonnelListViewModelTestError.sample)

        let result = await vm.runBulkQuery(
            businessId: "business-1",
            start: Date(),
            end: Date()
        )

        XCTAssertFalse(result)
        XCTAssertEqual(vm.bulkError, PersonnelListViewModelTestError.sample.localizedDescription)
        XCTAssertFalse(vm.isBulkLoading)
    }

    func testScoreTextFindsScoreByUserId() {
        vm.bulkScoresByUserId = [
            "user-1": 91
        ]

        let member = makeMember(
            id: "member-1",
            userId: "USER-1",
            fullName: "Ali Veli",
            email: "ali@test.com"
        )

        XCTAssertEqual(vm.scoreText(for: member), "91")
    }

    func testScoreTextFindsScoreByMemberId() {
        vm.bulkScoresByUserId = [
            "member-1": 76
        ]

        let member = makeMember(
            id: "MEMBER-1",
            userId: "user-x",
            fullName: "Ali Veli",
            email: "ali@test.com"
        )

        XCTAssertEqual(vm.scoreText(for: member), "76")
    }

    func testScoreTextFindsScoreByNameFallback() {
        vm.bulkScoresByUserId = [
            "name:ali veli": 82
        ]

        let member = makeMember(
            id: "member-x",
            userId: "user-x",
            fullName: "Ali Veli",
            email: "ali@test.com"
        )

        XCTAssertEqual(vm.scoreText(for: member), "82")
    }

    func testScoreTextWhenScoreMissingReturnsNil() {
        let member = makeMember(
            id: "member-1",
            userId: "user-1",
            fullName: "Ali Veli",
            email: "ali@test.com"
        )

        XCTAssertNil(vm.scoreText(for: member))
    }

    private func makeMember(
        id: String,
        userId: String,
        fullName: String,
        email: String
    ) -> BusinessMemberDTO {
        BusinessMemberDTO(
            id: id,
            userId: userId,
            fullName: fullName,
            email: email,
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
    }
}

// MARK: - Mock UseCase

private final class MockQueryBulkPerformanceScoresUseCase: QueryBulkPerformanceScoresUseCaseProtocol {

    var result: Result<[PerformanceBulkScoreItemDTO], Error> = .success([])

    func execute(
        businessId: String,
        start: Date,
        end: Date
    ) async throws -> [PerformanceBulkScoreItemDTO] {
        try result.get()
    }
}

// MARK: - Mock DTO Helper

private func makeBulkScore(
    employeeUserId: String?,
    calisanId: String?,
    performanceScore: Double?,
    fullName: String?
) -> PerformanceBulkScoreItemDTO {
    let json: [String: Any?] = [
        "employeeUserId": employeeUserId,
        "calisan_id": calisanId,
        "performanceScore": performanceScore,
        "fullName": fullName
    ]

    let cleanJson = json.compactMapValues { $0 }
    let data = try! JSONSerialization.data(withJSONObject: cleanJson)
    return try! JSONDecoder().decode(PerformanceBulkScoreItemDTO.self, from: data)
}

// MARK: - Error

private enum PersonnelListViewModelTestError: LocalizedError {
    case sample

    var errorDescription: String? {
        "Test hatası"
    }
}
