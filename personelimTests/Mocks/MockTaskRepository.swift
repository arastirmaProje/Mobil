//
//  MockTaskRepository.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import Foundation
@testable import personelim

final class MockTaskRepository: TaskRepositoryProtocol {

    var tasksResult: Result<[TaskEntity], Error> = .success([])

    func getMyTasks() async throws -> [TaskEntity] {
        switch tasksResult {
        case .success(let tasks):
            return tasks
        case .failure(let error):
            throw error
        }
    }

    /// Unused methods
    func createTask(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        assignedToUserId: String
    ) async throws {}

    func updateTaskStatus(
        taskId: String,
        status: String,
        thoughts: String,
        difficulty: String
    ) async throws {}
}
