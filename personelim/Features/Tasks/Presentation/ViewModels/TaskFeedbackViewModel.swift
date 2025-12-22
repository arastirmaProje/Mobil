//
//  TaskFeedbackViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

import Foundation

@MainActor
final class TaskFeedbackViewModel: ObservableObject {

    @Published var feedbackText: String = ""
    @Published var difficulty: Int = 3
    @Published var isSaving = false
    @Published var errorMessage: String?

    let taskId: String
    private let repo: TaskRepositoryProtocol

    init(taskId: String, repo: TaskRepositoryProtocol) {
        self.taskId = taskId
        self.repo = repo
    }

    var isValid: Bool {
        !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var difficultyText: String {
        switch difficulty {
        case 1: return "Çok Kolay"
        case 2: return "Kolay"
        case 3: return "Orta"
        case 4: return "Zor"
        case 5: return "Çok Zor"
        default: return "Orta"
        }
    }

    func submit() async -> Bool {
        guard isValid else { return false }

        isSaving = true
        defer { isSaving = false }

        do {
            try await repo.updateTaskStatus(
                taskId: taskId,
                status: "Tamamlandı",
                thoughts: feedbackText,
                difficulty: difficultyText
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
