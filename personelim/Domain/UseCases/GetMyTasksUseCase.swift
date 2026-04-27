//
//  GetMyTasksUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 20.12.2025.
//

import Foundation

final class GetMyTasksUseCase {

    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [TaskEntity] {
        try await repository.getMyTasks()
    }
}

final class GetActivitiesUseCase {
    private let taskRepository: TaskRepositoryProtocol
    private let scheduleRepository: ScheduleRepositoryProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        scheduleRepository: ScheduleRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.scheduleRepository = scheduleRepository
    }

    func execute(businessId: String) async throws -> [TaskEntity] {
        let tasks = try await taskRepository.getMyTasks()
        let schedules = (try? await scheduleRepository.getSchedules(businessId: businessId)) ?? []
        return tasks + schedules
    }
}

struct DeleteActivityUseCase {
    private let taskRepository: TaskRepositoryProtocol
    private let scheduleRepository: ScheduleRepositoryProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        scheduleRepository: ScheduleRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.scheduleRepository = scheduleRepository
    }

    func execute(activityId: String, activityType: ActivityType) async throws {
        if activityType == .task {
            try await taskRepository.deleteTask(taskId: activityId)
        } else {
            try await scheduleRepository.deleteSchedule(scheduleId: activityId)
        }
    }
}

struct UpdateActivityStatusUseCase {
    private let taskRepository: TaskRepositoryProtocol
    private let scheduleRepository: ScheduleRepositoryProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        scheduleRepository: ScheduleRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.scheduleRepository = scheduleRepository
    }

    func execute(
        activityId: String,
        activityType: ActivityType,
        status: String,
        thoughts: String,
        difficulty: String
    ) async throws {
        guard activityType == .task else { return }
        try await taskRepository.updateTaskStatus(
            taskId: activityId,
            status: status,
            thoughts: thoughts,
            difficulty: difficulty
        )
    }
}
