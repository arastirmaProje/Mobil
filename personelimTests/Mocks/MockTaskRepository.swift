import Foundation
@testable import personelim

final class MockTaskRepository: TaskRepositoryProtocol {

    var tasksResult: Result<[TaskEntity], Error> = .success([])
    var createTaskResult: Result<Void, Error> = .success(())
    var deleteTaskResult: Result<Void, Error> = .success(())

    var createTaskCallCount = 0
    var receivedBusinessId: String?
    var receivedTitle: String?
    var receivedDescription: String?
    var receivedStartDate: Date?
    var receivedEndDate: Date?
    var receivedAssignedUserId: String?
    var receivedAssignedUserIds: [String] = []
    
    var updateTaskStatusResult: Result<Void, Error> = .success(())

    var updateTaskStatusCallCount = 0
    var receivedUpdateTaskId: String?
    var receivedUpdateStatus: String?
    var receivedUpdateThoughts: String?
    var receivedUpdateDifficulty: String?

    var deleteTaskCallCount = 0
    var deletedTaskId: String?

    func getMyTasks() async throws -> [TaskEntity] {
        try tasksResult.get()
    }

    func createTask(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        assignedToUserId: String
    ) async throws {
        createTaskCallCount += 1
        receivedBusinessId = businessId
        receivedTitle = title
        receivedDescription = description
        receivedStartDate = startDate
        receivedEndDate = endDate
        receivedAssignedUserId = assignedToUserId
        receivedAssignedUserIds.append(assignedToUserId)

        try createTaskResult.get()
    }

    func updateTaskStatus(
        taskId: String,
        status: String,
        thoughts: String,
        difficulty: String
    ) async throws {
        updateTaskStatusCallCount += 1
        receivedUpdateTaskId = taskId
        receivedUpdateStatus = status
        receivedUpdateThoughts = thoughts
        receivedUpdateDifficulty = difficulty

        try updateTaskStatusResult.get()
    }

    func deleteTask(taskId: String) async throws {
        deleteTaskCallCount += 1
        deletedTaskId = taskId

        try deleteTaskResult.get()
    }
}

final class MockScheduleRepository: ScheduleRepositoryProtocol {

    var schedulesResult: Result<[TaskEntity], Error> = .success([])
    var createScheduleResult: Result<Void, Error> = .success(())
    var deleteScheduleResult: Result<Void, Error> = .success(())

    var createScheduleCallCount = 0
    var receivedBusinessId: String?
    var receivedTitle: String?
    var receivedDescription: String?
    var receivedDate: Date?
    var receivedActivityType: ActivityType?

    var deleteScheduleCallCount = 0
    var deletedScheduleId: String?

    func getSchedules(businessId: String) async throws -> [TaskEntity] {
        try schedulesResult.get()
    }

    func createSchedule(
        businessId: String,
        title: String,
        description: String,
        date: Date,
        activityType: ActivityType
    ) async throws {
        createScheduleCallCount += 1
        receivedBusinessId = businessId
        receivedTitle = title
        receivedDescription = description
        receivedDate = date
        receivedActivityType = activityType

        try createScheduleResult.get()
    }

    func deleteSchedule(scheduleId: String) async throws {
        deleteScheduleCallCount += 1
        deletedScheduleId = scheduleId

        try deleteScheduleResult.get()
    }
}
