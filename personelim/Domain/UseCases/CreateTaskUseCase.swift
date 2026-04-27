//
//  CreateTaskUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 22.12.2025.
//

import Foundation

struct CreateTaskUseCase {

    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        assignedToUserId: String
    ) async throws {
        try await repository.createTask(
            businessId: businessId,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            assignedToUserId: assignedToUserId
        )
    }
}

struct CreateActivityUseCase {
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
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        assignedToUserId: String,
        activityType: ActivityType
    ) async throws {
        if activityType == .task {
            try await taskRepository.createTask(
                businessId: businessId,
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                assignedToUserId: assignedToUserId
            )
        } else {
            try await scheduleRepository.createSchedule(
                businessId: businessId,
                title: title,
                description: description,
                date: startDate,
                activityType: activityType
            )
        }
    }
}
