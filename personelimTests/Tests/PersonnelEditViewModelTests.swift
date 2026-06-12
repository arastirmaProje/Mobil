import XCTest
@testable import personelim

@MainActor
final class PersonnelEditViewModelTests: XCTestCase {

    private var updateUseCase: MockUpdateBusinessMemberUseCase!
    private var deleteUseCase: MockDeleteBusinessMemberUseCase!
    private var repo: BusinessMemberRepositoryProtocol!
    private var vm: PersonnelEditViewModel!

    override func setUp() {
        super.setUp()

        updateUseCase = MockUpdateBusinessMemberUseCase()
        deleteUseCase = MockDeleteBusinessMemberUseCase()
        repo = BusinessMemberRepositoryImpl(network: NetworkManager())

        vm = PersonnelEditViewModel(
            memberRepo: repo,
            updateUseCase: updateUseCase,
            deleteUseCase: deleteUseCase
        )
    }

    override func tearDown() {
        vm = nil
        repo = nil
        updateUseCase = nil
        deleteUseCase = nil

        super.tearDown()
    }

    func testPrefillSetsPositionIdPositionAndSalary() {
        let member = makeMember(
            positionId: 12,
            positionName: "iOS Developer",
            salary: 45000
        )

        vm.prefill(from: member)

        XCTAssertEqual(vm.selectedPositionId, 12)
        XCTAssertEqual(vm.position, "iOS Developer")
        XCTAssertEqual(vm.salaryText, "45000")
    }

    func testPrefillWhenValuesNilSetsDefaults() {
        let member = makeMember(
            positionId: nil,
            positionName: nil,
            salary: nil
        )

        vm.prefill(from: member)

        XCTAssertEqual(vm.selectedPositionId, 0)
        XCTAssertEqual(vm.position, "")
        XCTAssertEqual(vm.salaryText, "")
    }

    func testSaveWhenPositionNotSelectedSetsErrorAndDoesNotCallUpdate() async {
        let member = makeMember()

        vm.selectedPositionId = 0
        vm.salaryText = "50000"

        await vm.save(
            memberId: "member-1",
            original: member
        )

        XCTAssertEqual(vm.errorMessage, "Lütfen bir ünvan seç.")
        XCTAssertFalse(vm.didUpdate)
        XCTAssertFalse(updateUseCase.didCallExecute)
        XCTAssertFalse(vm.isLoading)
    }

    func testSaveWhenValidCallsUpdateAndSetsDidUpdate() async {
        let member = makeMember()

        vm.selectedPositionId = 5
        vm.salaryText = "50000"

        await vm.save(
            memberId: "member-1",
            original: member
        )

        XCTAssertNil(vm.errorMessage)
        XCTAssertTrue(vm.didUpdate)
        XCTAssertEqual(vm.updatedMember?.id, member.id)
        XCTAssertTrue(updateUseCase.didCallExecute)
        XCTAssertEqual(updateUseCase.receivedMemberId, "member-1")
        XCTAssertEqual(updateUseCase.receivedBody?.positionId, 5)
        XCTAssertEqual(updateUseCase.receivedBody?.salary, 50000)
        XCTAssertFalse(vm.isLoading)
    }

    func testSaveConvertsCommaSalaryToDouble() async {
        let member = makeMember()

        vm.selectedPositionId = 5
        vm.salaryText = "50000,50"

        await vm.save(
            memberId: "member-1",
            original: member
        )

        XCTAssertEqual(updateUseCase.receivedBody?.salary, 50000.50)
    }

    func testSaveWhenSalaryEmptySendsNilSalary() async {
        let member = makeMember()

        vm.selectedPositionId = 5
        vm.salaryText = ""

        await vm.save(
            memberId: "member-1",
            original: member
        )

        XCTAssertNil(updateUseCase.receivedBody?.salary)
    }

    func testSaveWhenUpdateFailsSetsErrorMessage() async {
        let member = makeMember()

        vm.selectedPositionId = 5
        vm.salaryText = "50000"
        updateUseCase.errorToThrow = PersonnelEditTestError.sample

        await vm.save(
            memberId: "member-1",
            original: member
        )

        XCTAssertEqual(
            vm.errorMessage,
            PersonnelEditTestError.sample.localizedDescription
        )
        XCTAssertFalse(vm.didUpdate)
        XCTAssertFalse(vm.isLoading)
    }

    func testDeleteWhenSuccessSetsDidDelete() async {
        await vm.delete(memberId: "member-1")

        XCTAssertNil(vm.errorMessage)
        XCTAssertTrue(vm.didDelete)
        XCTAssertTrue(deleteUseCase.didCallExecute)
        XCTAssertEqual(deleteUseCase.receivedMemberId, "member-1")
        XCTAssertFalse(vm.isLoading)
    }

    func testDeleteWhenFailsSetsErrorMessage() async {
        deleteUseCase.errorToThrow = PersonnelEditTestError.sample

        await vm.delete(memberId: "member-1")

        XCTAssertEqual(
            vm.errorMessage,
            PersonnelEditTestError.sample.localizedDescription
        )
        XCTAssertFalse(vm.didDelete)
        XCTAssertFalse(vm.isLoading)
    }

    private func makeMember(
        positionId: Int? = 1,
        positionName: String? = "Developer",
        salary: Double? = 45000
    ) -> BusinessMemberDTO {
        BusinessMemberDTO(
            id: "member-1",
            userId: "user-1",
            fullName: "Test User",
            email: "test@test.com",
            departmentId: "dept-1",
            positionId: positionId,
            phoneNumber: nil,
            role: .employee,
            positionName: positionName,
            salary: salary,
            tcIdentityNumber: "11111111111",
            position: positionName,
            joinedAt: nil,
            isActive: true,
            documents: nil
        )
    }
}

// MARK: - Mocks

private final class MockUpdateBusinessMemberUseCase: UpdateBusinessMemberUseCaseProtocol {

    var didCallExecute = false
    var receivedMemberId: String?
    var receivedBody: UpdateBusinessMemberRequestDTO?
    var errorToThrow: Error?

    func execute(
        memberId: String,
        body: UpdateBusinessMemberRequestDTO
    ) async throws {
        didCallExecute = true
        receivedMemberId = memberId
        receivedBody = body

        if let errorToThrow {
            throw errorToThrow
        }
    }
}

private final class MockDeleteBusinessMemberUseCase: DeleteBusinessMemberUseCaseProtocol {

    var didCallExecute = false
    var receivedMemberId: String?
    var errorToThrow: Error?

    func execute(memberId: String) async throws {
        didCallExecute = true
        receivedMemberId = memberId

        if let errorToThrow {
            throw errorToThrow
        }
    }
}

private enum PersonnelEditTestError: LocalizedError {
    case sample

    var errorDescription: String? {
        "Test hatası"
    }
}
