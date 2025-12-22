//
//  TaskDetailViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

import Foundation

@MainActor
final class TaskDetailViewModel: ObservableObject {

    enum TaskStatusOption: String, CaseIterable {
        case completed = "Tamamlandı"
        case pending = "Tamamlanmadı"
    }

    @Published var selectedStatus: TaskStatusOption?
    @Published var showStatusOptions = false
    @Published var navigateToFeedback = false

    let task: TaskEntity

    init(task: TaskEntity) {
        self.task = task
    }

    var isCompletedSelected: Bool {
        selectedStatus == .completed
    }
}
