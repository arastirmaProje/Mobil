//
//  CreateTaskViewModelTests.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import XCTest
@testable import personelim

@MainActor
final class CreateTaskViewModelTests: XCTestCase {

    private var taskRepository: MockTaskRepository!
    private var scheduleRepository: MockScheduleRepository!
    private var vm: CreateTaskViewModel!

    override func setUp() {
        super.setUp()

        taskRepository = MockTaskRepository()
        scheduleRepository = MockScheduleRepository()

        let useCase = CreateActivityUseCase(
            taskRepository: taskRepository,
            scheduleRepository: scheduleRepository
        )

        vm = CreateTaskViewModel(createActivityUseCase: useCase)
    }

    override func tearDown() {
        vm = nil
        taskRepository = nil
        scheduleRepository = nil
        super.tearDown()
    }

    func testIsFormValidWhenTitleEmptyReturnsFalse() {
        vm.title = ""
        vm.startDate = Date()
        vm.endDate = Date()
        vm.activityType = .meeting

        XCTAssertFalse(vm.isFormValid)
    }

    func testIsFormValidWhenDatesMissingReturnsFalse() {
        vm.title = "Toplantı"
        vm.startDate = nil
        vm.endDate = nil
        vm.activityType = .meeting

        XCTAssertFalse(vm.isFormValid)
    }

    func testIsFormValidForMeetingWithoutAssigneeReturnsTrue() {
        vm.title = "Toplantı"
        vm.startDate = Date()
        vm.endDate = Date()
        vm.activityType = .meeting
        vm.selectedAssignees = []

        XCTAssertTrue(vm.isFormValid)
    }

    func testIsFormValidForTaskWithoutAssigneeReturnsFalse() {
        vm.title = "Görev"
        vm.startDate = Date()
        vm.endDate = Date()
        vm.activityType = .task
        vm.selectedAssignees = []

        XCTAssertFalse(vm.isFormValid)
    }

    func testIsFormValidForTaskWithAssigneeReturnsTrue() {
        vm.title = "Görev"
        vm.startDate = Date()
        vm.endDate = Date()
        vm.activityType = .task
        vm.selectedAssignees = ["user-1"]

        XCTAssertTrue(vm.isFormValid)
    }

    func testCreateTaskWhenDatesMissingReturnsFalse() async {
        vm.title = "Görev"
        vm.activityType = .task
        vm.startDate = nil
        vm.endDate = nil
        vm.selectedAssignees = ["user-1"]

        let result = await vm.createTask(businessId: "business-1")

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, ConstantStrings.dateRangeNotSelectedError)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(taskRepository.createTaskCallCount, 0)
        XCTAssertEqual(scheduleRepository.createScheduleCallCount, 0)
    }

    func testCreateMeetingCallsScheduleRepositoryOnce() async {
        let start = Date(timeIntervalSince1970: 1000)
        let end = Date(timeIntervalSince1970: 2000)

        vm.title = "Haftalık toplantı"
        vm.detail = "Detay"
        vm.activityType = .meeting
        vm.startDate = start
        vm.endDate = end

        let result = await vm.createTask(businessId: "business-1")

        XCTAssertTrue(result)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)

        XCTAssertEqual(scheduleRepository.createScheduleCallCount, 1)
        XCTAssertEqual(scheduleRepository.receivedBusinessId, "business-1")
        XCTAssertEqual(scheduleRepository.receivedTitle, "Haftalık toplantı")
        XCTAssertEqual(scheduleRepository.receivedDescription, "Detay")
        XCTAssertEqual(scheduleRepository.receivedDate, start)
        XCTAssertEqual(scheduleRepository.receivedActivityType, .meeting)

        XCTAssertEqual(taskRepository.createTaskCallCount, 0)
    }

    func testCreateEventCallsScheduleRepositoryOnce() async {
        let date = Date(timeIntervalSince1970: 3000)

        vm.title = "Etkinlik"
        vm.detail = "Etkinlik detayı"
        vm.activityType = .event
        vm.startDate = date
        vm.endDate = date

        let result = await vm.createTask(businessId: "business-1")

        XCTAssertTrue(result)
        XCTAssertEqual(scheduleRepository.createScheduleCallCount, 1)
        XCTAssertEqual(scheduleRepository.receivedActivityType, .event)
        XCTAssertEqual(taskRepository.createTaskCallCount, 0)
    }

    func testCreateTaskCallsTaskRepositoryForEachAssignee() async {
        let start = Date(timeIntervalSince1970: 1000)
        let end = Date(timeIntervalSince1970: 2000)

        vm.title = "Yeni görev"
        vm.detail = "Görev detayı"
        vm.activityType = .task
        vm.startDate = start
        vm.endDate = end
        vm.selectedAssignees = ["user-1", "user-2"]

        let result = await vm.createTask(businessId: "business-1")

        XCTAssertTrue(result)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)

        XCTAssertEqual(taskRepository.createTaskCallCount, 2)
        XCTAssertEqual(Set(taskRepository.receivedAssignedUserIds), ["user-1", "user-2"])
        XCTAssertEqual(scheduleRepository.createScheduleCallCount, 0)
    }

    func testCreateTaskNormalizesReversedDates() async {
        let later = Date(timeIntervalSince1970: 3000)
        let earlier = Date(timeIntervalSince1970: 1000)

        vm.title = "Ters tarihli görev"
        vm.detail = "Detay"
        vm.activityType = .task
        vm.startDate = later
        vm.endDate = earlier
        vm.selectedAssignees = ["user-1"]

        let result = await vm.createTask(businessId: "business-1")

        XCTAssertTrue(result)
        XCTAssertEqual(taskRepository.receivedStartDate, earlier)
        XCTAssertEqual(taskRepository.receivedEndDate, later)
    }

    func testCreateTaskWhenRepositoryFailsSetsErrorMessage() async {
        taskRepository.createTaskResult = .failure(CreateTaskViewModelTestError.sample)

        vm.title = "Hatalı görev"
        vm.detail = "Detay"
        vm.activityType = .task
        vm.startDate = Date()
        vm.endDate = Date()
        vm.selectedAssignees = ["user-1"]

        let result = await vm.createTask(businessId: "business-1")

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, CreateTaskViewModelTestError.sample.localizedDescription)
        XCTAssertFalse(vm.isLoading)
    }

    func testCreateMeetingWhenRepositoryFailsSetsErrorMessage() async {
        scheduleRepository.createScheduleResult = .failure(CreateTaskViewModelTestError.sample)

        vm.title = "Hatalı toplantı"
        vm.detail = "Detay"
        vm.activityType = .meeting
        vm.startDate = Date()
        vm.endDate = Date()

        let result = await vm.createTask(businessId: "business-1")

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, CreateTaskViewModelTestError.sample.localizedDescription)
        XCTAssertFalse(vm.isLoading)
    }
}

private enum CreateTaskViewModelTestError: LocalizedError {
    case sample

    var errorDescription: String? {
        "Test hatası"
    }
}
