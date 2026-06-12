import XCTest
@testable import personelim

@MainActor
final class DepartmentViewModelTests: XCTestCase {

    private var repo: MockDepartmentRepository!
    private var vm: DepartmentViewModel!

    override func setUp() {
        super.setUp()
        repo = MockDepartmentRepository()
        vm = DepartmentViewModel(repository: repo)
    }

    override func tearDown() {
        vm = nil
        repo = nil
        super.tearDown()
    }

    func testFetchDepartmentsWhenBusinessIdEmptySetsError() async {
        await vm.fetchDepartments(businessId: "")

        XCTAssertEqual(vm.errorMessage, ConstantStrings.businessInfoNotFoundError)
        XCTAssertFalse(repo.didCallFetchDepartments)
        XCTAssertFalse(vm.isLoading)
    }

    func testFetchDepartmentsSuccessSetsDepartments() async {
        repo.departmentsToReturn = [
            makeDepartment(id: "dept-1", name: "İnsan Kaynakları"),
            makeDepartment(id: "dept-2", name: "Yazılım")
        ]

        await vm.fetchDepartments(businessId: "business-1")

        XCTAssertTrue(repo.didCallFetchDepartments)
        XCTAssertEqual(repo.receivedBusinessId, "business-1")
        XCTAssertEqual(vm.departments.count, 2)
        XCTAssertEqual(vm.departments[0].name, "İnsan Kaynakları")
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    func testFetchDepartmentsFailureSetsError() async {
        repo.errorToThrow = DepartmentViewModelTestError.sample

        await vm.fetchDepartments(businessId: "business-1")

        XCTAssertEqual(vm.errorMessage, DepartmentViewModelTestError.sample.localizedDescription)
        XCTAssertTrue(vm.departments.isEmpty)
        XCTAssertFalse(vm.isLoading)
    }

    func testFetchCategoriesWhenEmptyLoadsCategories() async {
        repo.categoriesToReturn = [
            makeCategory(id: 1, name: "Yönetim"),
            makeCategory(id: 2, name: "Teknik")
        ]

        await vm.fetchCategories()

        XCTAssertTrue(repo.didCallFetchCategories)
        XCTAssertEqual(vm.categories.count, 2)
        XCTAssertEqual(vm.categories[0].name, "Yönetim")
    }

    func testFetchCategoriesWhenAlreadyLoadedDoesNotCallRepositoryAgain() async {
        repo.categoriesToReturn = [
            makeCategory(id: 1, name: "Yönetim")
        ]

        await vm.fetchCategories()
        await vm.fetchCategories()

        XCTAssertEqual(repo.fetchCategoriesCallCount, 1)
        XCTAssertEqual(vm.categories.count, 1)
    }

    func testCreateDepartmentWhenNameEmptySetsError() async {
        await vm.createDepartment(
            name: "",
            businessId: "business-1",
            categoryId: 1
        )

        XCTAssertEqual(vm.errorMessage, ConstantStrings.departmentNameEmptyError)
        XCTAssertFalse(repo.didCallCreateDepartment)
        XCTAssertFalse(vm.isLoading)
    }

    func testCreateDepartmentSuccessCreatesAndRefreshesDepartments() async {
        repo.departmentsToReturn = [
            makeDepartment(id: "dept-1", name: "Yazılım")
        ]

        await vm.createDepartment(
            name: "Yazılım",
            businessId: "business-1",
            categoryId: 2
        )

        XCTAssertTrue(repo.didCallCreateDepartment)
        XCTAssertEqual(repo.receivedCreateRequest?.name, "Yazılım")
        XCTAssertEqual(repo.receivedCreateRequest?.businessId, "business-1")
        XCTAssertEqual(repo.receivedCreateRequest?.categoryId, 2)
        XCTAssertTrue(repo.didCallFetchDepartments)
        XCTAssertEqual(vm.departments.count, 1)
        XCTAssertEqual(vm.departments.first?.name, "Yazılım")
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    func testCreateDepartmentFailureSetsError() async {
        repo.errorToThrow = DepartmentViewModelTestError.sample

        await vm.createDepartment(
            name: "Yazılım",
            businessId: "business-1",
            categoryId: 2
        )

        XCTAssertEqual(vm.errorMessage, DepartmentViewModelTestError.sample.localizedDescription)
        XCTAssertFalse(vm.isLoading)
    }

    func testUpdateDepartmentSuccessUpdatesAndRefreshesDepartments() async {
        repo.departmentsToReturn = [
            makeDepartment(id: "dept-1", name: "Yeni Ad")
        ]

        await vm.updateDepartment(
            id: "dept-1",
            name: "Yeni Ad",
            categoryId: 3,
            businessId: "business-1"
        )

        XCTAssertTrue(repo.didCallUpdateDepartment)
        XCTAssertEqual(repo.receivedUpdateId, "dept-1")
        XCTAssertEqual(repo.receivedUpdateName, "Yeni Ad")
        XCTAssertEqual(repo.receivedUpdateCategoryId, 3)
        XCTAssertTrue(repo.didCallFetchDepartments)
        XCTAssertEqual(vm.departments.first?.name, "Yeni Ad")
    }

    func testUpdateDepartmentFailureSetsError() async {
        repo.errorToThrow = DepartmentViewModelTestError.sample

        await vm.updateDepartment(
            id: "dept-1",
            name: "Yeni Ad",
            categoryId: 3,
            businessId: "business-1"
        )

        XCTAssertEqual(vm.errorMessage, DepartmentViewModelTestError.sample.localizedDescription)
    }

    func testDeleteDepartmentSuccessDeletesAndRefreshesDepartments() async {
        repo.departmentsToReturn = []

        await vm.deleteDepartment(
            id: "dept-1",
            businessId: "business-1"
        )

        XCTAssertTrue(repo.didCallDeleteDepartment)
        XCTAssertEqual(repo.receivedDeleteId, "dept-1")
        XCTAssertTrue(repo.didCallFetchDepartments)
        XCTAssertTrue(vm.departments.isEmpty)
    }

    func testDeleteDepartmentFailureSetsError() async {
        repo.errorToThrow = DepartmentViewModelTestError.sample

        await vm.deleteDepartment(
            id: "dept-1",
            businessId: "business-1"
        )

        XCTAssertEqual(vm.errorMessage, DepartmentViewModelTestError.sample.localizedDescription)
    }

    func testFetchDepartmentPerformanceSuccessSetsPerformance() async {
        repo.performanceToReturn = makeMockDepartmentPerformance()

        await vm.fetchDepartmentPerformance(
            businessId: "business-1",
            departmentId: "dept-1",
            startDate: Date(timeIntervalSince1970: 1000),
            endDate: Date(timeIntervalSince1970: 2000)
        )

        XCTAssertTrue(repo.didCallQueryDepartmentPerformance)
        XCTAssertEqual(repo.receivedPerformanceRequest?.businessId, "business-1")
        XCTAssertEqual(repo.receivedPerformanceRequest?.departmentId, "dept-1")
        XCTAssertEqual(vm.departmentPerformance?.departmanAdi, "Yazılım")
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isPerformanceLoading)
    }

    func testFetchDepartmentPerformanceFailureSetsError() async {
        repo.errorToThrow = DepartmentViewModelTestError.sample

        await vm.fetchDepartmentPerformance(
            businessId: "business-1",
            departmentId: "dept-1",
            startDate: Date(),
            endDate: Date()
        )

        XCTAssertEqual(vm.errorMessage, DepartmentViewModelTestError.sample.localizedDescription)
        XCTAssertNil(vm.departmentPerformance)
        XCTAssertFalse(vm.isPerformanceLoading)
    }

    func testFetchDepartmentChartsWhenBusinessIdEmptyDoesNothing() async {
        await vm.fetchDepartmentCharts(
            businessId: "",
            startDate: Date(),
            endDate: Date()
        )

        XCTAssertFalse(repo.didCallFetchDepartmentCharts)
        XCTAssertNil(vm.businessCharts)
        XCTAssertFalse(vm.isChartsLoading)
    }

    func testFetchDepartmentChartsSuccessSetsBusinessCharts() async {
        repo.businessChartsToReturn = makeMockBusinessCharts()

        await vm.fetchDepartmentCharts(
            businessId: "business-1",
            startDate: Date(timeIntervalSince1970: 1000),
            endDate: Date(timeIntervalSince1970: 2000)
        )

        XCTAssertTrue(repo.didCallFetchDepartmentCharts)
        XCTAssertEqual(repo.receivedChartsBusinessId, "business-1")
        XCTAssertEqual(vm.businessCharts?.toplamDepartman, 1)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isChartsLoading)
    }

    func testFetchDepartmentChartsFailureSetsError() async {
        repo.errorToThrow = DepartmentViewModelTestError.sample

        await vm.fetchDepartmentCharts(
            businessId: "business-1",
            startDate: Date(),
            endDate: Date()
        )

        XCTAssertEqual(
            vm.errorMessage,
            "Grafik yüklenemedi: \(DepartmentViewModelTestError.sample.localizedDescription)"
        )
        XCTAssertNil(vm.businessCharts)
        XCTAssertFalse(vm.isChartsLoading)
    }

    private func makeDepartment(
        id: String,
        name: String
    ) -> DepartmentResponseDTO {
        DepartmentResponseDTO(
            id: id,
            businessId: "business-1",
            categoryId: 1,
            name: name,
            memberCount: 3,
            createdAt: "2026-01-01T00:00:00Z"
        )
    }

    private func makeCategory(
        id: Int,
        name: String
    ) -> JobCategoryDTO {
        JobCategoryDTO(
            id: id,
            name: name
        )
    }
}
