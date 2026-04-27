//
//  TaskRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 20.12.2025.
//

import Foundation

final class TaskRepositoryImpl: TaskRepositoryProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    // MARK: - Get My Tasks
    func getMyTasks() async throws -> [TaskEntity] {
        let taskResponse: ServiceResponse<[TaskDTO]> = try await network.request(
            endpoint: .myTasks,
            method: .get,
            body: nil
        )
        return (taskResponse.data ?? []).map { $0.toEntity() }
    }

    // MARK: - Create Task
    func createTask(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        assignedToUserId: String
    ) async throws {

        let body = CreateTaskRequestDTO(
            businessId: businessId,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            assignedToUserId: assignedToUserId
        )

        let _: ServiceResponse<EmptyResponse> = try await network.request(
            endpoint: .createTask,
            method: .post,
            body: body
        )
    }

    // MARK: - Update Task Status (Complete / Feedback)
    func updateTaskStatus(
        taskId: String,
        status: String,
        thoughts: String,
        difficulty: String
    ) async throws {

        let body = UpdateTaskStatusRequestDTO(
            status: status,
            thoughts: thoughts,
            difficulty: difficulty
        )

        let _: ServiceResponse<EmptyResponse> = try await network.request(
            endpoint: .updateTaskStatus(taskId: taskId),
            method: .put,
            body: body
        )
    }

    func deleteTask(taskId: String) async throws {
        let _: ServiceResponse<EmptyResponse> = try await network.request(
            endpoint: .deleteTask(taskId: taskId),
            method: .delete,
            body: nil
        )
    }
}
