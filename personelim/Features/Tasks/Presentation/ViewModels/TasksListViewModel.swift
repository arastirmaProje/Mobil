//
//  TasksListViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

import Foundation

@MainActor
final class TasksListViewModel: ObservableObject {

    // MARK: - UI State
    @Published var activeTasks: [TaskEntity] = []
    @Published var pastTasks: [TaskEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - UseCase
    private let getMyTasksUseCase: GetMyTasksUseCase

    init() {
        let network = NetworkManager()
        let repo = TaskRepositoryImpl(network: network)
        self.getMyTasksUseCase = GetMyTasksUseCase(repository: repo)
    }

    // MARK: - Load
    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            let tasks = try await getMyTasksUseCase.execute()
            mapTasks(tasks)
        } catch {
            errorMessage = "Görevler yüklenemedi"
            print("🔴 TASK LOAD ERROR:", error)
        }

        isLoading = false
    }

    // MARK: - Business Logic
    private func mapTasks(_ tasks: [TaskEntity]) {
        let now = Date()

        activeTasks = tasks.filter {
            $0.status.lowercased() != "tamamlandı" &&
            $0.endDate >= now
        }

        pastTasks = tasks.filter {
            $0.status.lowercased() == "tamamlandı" ||
            $0.endDate < now
        }

        print("🟢 ACTIVE:", activeTasks.count)
        print("🟡 PAST:", pastTasks.count)
    }
}
