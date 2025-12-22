//
//  HomeViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.12.2025.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var activeTasks: [TaskEntity] = []
    @Published var isLoading = false

    private let taskRepo: TaskRepositoryProtocol

    init(taskRepo: TaskRepositoryProtocol = TaskRepositoryImpl(network: NetworkManager())) {
        self.taskRepo = taskRepo
    }

    func loadActiveTasks() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let tasks = try await taskRepo.getMyTasks()
            activeTasks = tasks.filter { $0.status == "Beklemede" }
        } catch {
            print("❌ Home task load error:", error)
        }
    }
}
