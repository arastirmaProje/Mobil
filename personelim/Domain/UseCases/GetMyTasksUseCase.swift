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
