//
//  TaskFeedbackViewModelTests.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import XCTest
@testable import personelim

@MainActor
final class TaskFeedbackViewModelTests: XCTestCase {

    private var taskRepository: MockTaskRepository!
    private var scheduleRepository: MockScheduleRepository!
    private var vm: TaskFeedbackViewModel!

    override func setUp() {
        super.setUp()

        taskRepository = MockTaskRepository()
        scheduleRepository = MockScheduleRepository()

        let useCase = UpdateActivityStatusUseCase(
            taskRepository: taskRepository,
            scheduleRepository: scheduleRepository
        )

        vm = TaskFeedbackViewModel(
            taskId: "task-1",
            activityType: .task,
            finalStatus: "DONE",
            updateStatusUseCase: useCase
        )
    }

    override func tearDown() {
        vm = nil
        taskRepository = nil
        scheduleRepository = nil
        super.tearDown()
    }

    func testIsValidWhenFeedbackEmptyReturnsFalse() {
        vm.feedbackText = ""

        XCTAssertFalse(vm.isValid)
    }

    func testIsValidWhenFeedbackOnlyWhitespaceReturnsFalse() {
        vm.feedbackText = "   \n  "

        XCTAssertFalse(vm.isValid)
    }

    func testIsValidWhenFeedbackFilledReturnsTrue() {
        vm.feedbackText = "Gayet iyi geçti."

        XCTAssertTrue(vm.isValid)
    }

    func testDifficultyTextReturnsCorrectValues() {
        vm.difficulty = 1
        XCTAssertEqual(vm.difficultyText, ConstantStrings.difficultyVeryEasy)

        vm.difficulty = 2
        XCTAssertEqual(vm.difficultyText, ConstantStrings.difficultyEasy)

        vm.difficulty = 3
        XCTAssertEqual(vm.difficultyText, ConstantStrings.difficultyMedium)

        vm.difficulty = 4
        XCTAssertEqual(vm.difficultyText, ConstantStrings.difficultyHard)

        vm.difficulty = 5
        XCTAssertEqual(vm.difficultyText, ConstantStrings.difficultyVeryHard)
    }

    func testDifficultyTextWhenOutOfRangeReturnsMedium() {
        vm.difficulty = 99

        XCTAssertEqual(vm.difficultyText, ConstantStrings.difficultyMedium)
    }

    func testSubmitWhenFeedbackEmptyReturnsFalseAndDoesNotCallRepository() async {
        vm.feedbackText = ""

        let result = await vm.submit()

        XCTAssertFalse(result)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isSaving)
        XCTAssertEqual(taskRepository.updateTaskStatusCallCount, 0)
    }

    func testSubmitWhenActivityTypeIsNotTaskReturnsFalseAndSetsError() async {
        let useCase = UpdateActivityStatusUseCase(
            taskRepository: taskRepository,
            scheduleRepository: scheduleRepository
        )

        vm = TaskFeedbackViewModel(
            taskId: "meeting-1",
            activityType: .meeting,
            finalStatus: "DONE",
            updateStatusUseCase: useCase
        )

        vm.feedbackText = "Toplantı tamamlandı."

        let result = await vm.submit()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, ConstantStrings.feedbackNotSupportedError)
        XCTAssertFalse(vm.isSaving)
        XCTAssertEqual(taskRepository.updateTaskStatusCallCount, 0)
    }

    func testSubmitSuccessCallsUpdateTaskStatus() async {
        vm.feedbackText = "Görev başarıyla tamamlandı."
        vm.difficulty = 4

        let result = await vm.submit()

        XCTAssertTrue(result)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isSaving)

        XCTAssertEqual(taskRepository.updateTaskStatusCallCount, 1)
        XCTAssertEqual(taskRepository.receivedUpdateTaskId, "task-1")
        XCTAssertEqual(taskRepository.receivedUpdateStatus, "DONE")
        XCTAssertEqual(taskRepository.receivedUpdateThoughts, "Görev başarıyla tamamlandı.")
        XCTAssertEqual(taskRepository.receivedUpdateDifficulty, ConstantStrings.difficultyHard)
    }

    func testSubmitWhenRepositoryFailsSetsErrorMessage() async {
        taskRepository.updateTaskStatusResult = .failure(TaskFeedbackViewModelTestError.sample)

        vm.feedbackText = "Kaydetme hatası testi."
        vm.difficulty = 2

        let result = await vm.submit()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, TaskFeedbackViewModelTestError.sample.localizedDescription)
        XCTAssertFalse(vm.isSaving)
        XCTAssertEqual(taskRepository.updateTaskStatusCallCount, 1)
    }
}

private enum TaskFeedbackViewModelTestError: LocalizedError {
    case sample

    var errorDescription: String? {
        "Test hatası"
    }
}
