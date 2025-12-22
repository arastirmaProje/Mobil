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
        let response: ServiceResponse<[TaskDTO]> = try await network.request(
            endpoint: .myTasks,
            method: .get,
            body: nil
        )
        print("🟢 RAW TASK RESPONSE:", response)
        let formatter = ISO8601DateFormatter()

        return (response.data ?? []).map { dto in
            TaskEntity(
                id: dto.id,
                title: dto.title ?? "",
                description: dto.description,
                assignedToName: dto.assignedToName,
                assignedByName: dto.assignedByName,
                startDate: formatter.date(from: dto.startDate) ?? .now,
                endDate: formatter.date(from: dto.endDate) ?? .now,
                status: dto.status,
                isOverdue: dto.isOverdue
            )
        }
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

        let body = [
            "status": status,
            "thoughts": thoughts,
            "difficulty": difficulty
        ]

        let _: ServiceResponse<EmptyResponse> = try await network.request(
            endpoint: .updateTaskStatus(taskId: taskId),
            method: .put,
            body: body
        )
    }
}
