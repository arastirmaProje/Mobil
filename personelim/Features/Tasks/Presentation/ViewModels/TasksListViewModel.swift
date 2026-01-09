//
//  TasksListViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

import Foundation

@MainActor
final class TasksListViewModel: ObservableObject {

    @Published var activeTasks: [TaskEntity] = []
    @Published var pastTasks: [TaskEntity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let getMyTasksUseCase: GetMyTasksUseCase
    private var didLoad = false

    init(
        useCase: GetMyTasksUseCase = GetMyTasksUseCase(
            repository: TaskRepositoryImpl(network: NetworkManager())
        )
    ) {
        self.getMyTasksUseCase = useCase

        Task {
            await loadIfNeeded()
        }
    }

    func loadIfNeeded() async {
        guard !didLoad else { return }
        didLoad = true
        await load()
    }

    func refresh() async {
        didLoad = false
        await loadIfNeeded()
    }

    private func load() async {
        isLoading = true
        errorMessage = nil

        do {
            let tasks = try await getMyTasksUseCase.execute()
            mapTasks(tasks)
            isLoading = false
        } catch {
            errorMessage = "Görevler yüklenemedi"
            isLoading = false
        }
    }

    private func mapTasks(_ tasks: [TaskEntity]) {
        let now = Date()

        activeTasks = tasks.filter {
            $0.statusEnum == .beklemede &&
            $0.endDate >= now
        }

        pastTasks = tasks.filter {
            $0.statusEnum == .tamamlandi ||
            $0.endDate < now
        }
    }
}
