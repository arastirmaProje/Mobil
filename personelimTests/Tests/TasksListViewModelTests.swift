//
//  TasksListViewModelTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

@MainActor
final class TasksListViewModelTests: XCTestCase {

    private var repository: MockTaskRepository!
    private var scheduleRepository: MockScheduleRepository!
    private var vm: TasksListViewModel!

    override func setUp() async throws {
        repository = MockTaskRepository()
        scheduleRepository = MockScheduleRepository()
        let getUseCase = GetActivitiesUseCase(
            taskRepository: repository,
            scheduleRepository: scheduleRepository
        )
        let deleteUseCase = DeleteActivityUseCase(
            taskRepository: repository,
            scheduleRepository: scheduleRepository
        )
        vm = TasksListViewModel(
            getActivitiesUseCase: getUseCase,
            deleteActivityUseCase: deleteUseCase
        )

        await Task.yield()
    }

    override func tearDown() {
        vm = nil
        repository = nil
        scheduleRepository = nil
        super.tearDown()
    }

    // MARK: - Success Load

    func test_load_tasks_success_mapsActiveAndPast() async {
        repository.tasksResult = .success([
            .activeMock(),
            .pastMock()
        ])

        await vm.refresh(businessId: "business-id")

        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)

        XCTAssertEqual(vm.activeTasks.count, 1)
        XCTAssertEqual(vm.pastTasks.count, 1)

        XCTAssertEqual(vm.activeTasks.first?.title, "Active Task")
        XCTAssertEqual(vm.pastTasks.first?.title, "Past Task")
    }

    // MARK: - Only Active

    func test_load_onlyActiveTasks() async {
        repository.tasksResult = .success([
            .activeMock(),
            .activeMock()
        ])

        await vm.refresh(businessId: "business-id")

        XCTAssertEqual(vm.activeTasks.count, 2)
        XCTAssertTrue(vm.pastTasks.isEmpty)
    }

    // MARK: - Only Past

    func test_load_onlyPastTasks() async {
        repository.tasksResult = .success([
            .pastMock(),
            .pastMock()
        ])

        await vm.refresh(businessId: "business-id")

        XCTAssertEqual(vm.pastTasks.count, 2)
        XCTAssertTrue(vm.activeTasks.isEmpty)
    }

    // MARK: - Failure

    func test_load_failure_setsErrorMessage() async {
        repository.tasksResult = .failure(NSError(domain: "test", code: -1))

        await vm.refresh(businessId: "business-id")

        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertTrue(vm.activeTasks.isEmpty)
        XCTAssertTrue(vm.pastTasks.isEmpty)
    }

    // MARK: - didLoad Guard

    func test_loadIfNeeded_calledOnce() async {
        repository.tasksResult = .success([.activeMock()])

        await vm.loadIfNeeded(businessId: "business-id")
        let firstCount = vm.activeTasks.count

        await vm.loadIfNeeded(businessId: "business-id")
        let secondCount = vm.activeTasks.count

        XCTAssertEqual(firstCount, secondCount)
    }
}
