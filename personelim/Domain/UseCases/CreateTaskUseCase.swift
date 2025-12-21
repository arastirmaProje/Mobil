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
