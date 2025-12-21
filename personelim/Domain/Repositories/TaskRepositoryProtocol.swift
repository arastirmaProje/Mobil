//
//  TaskRepositoryProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 20.12.2025.
//

import Foundation

protocol TaskRepositoryProtocol {
    func getMyTasks() async throws -> [TaskEntity]
    func createTask(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        assignedToUserId: String
    ) async throws
}
