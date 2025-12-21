//
//  CreateTaskViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

import Foundation

@MainActor
final class CreateTaskViewModel: ObservableObject {

    // MARK: - Input
    @Published var title: String = ""
    @Published var detail: String = ""
    @Published var selectedDates: Set<DateComponents> = []
    @Published var selectedAssignee: BusinessMemberDTO?

    // MARK: - State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Navigation
    @Published var showAssigneePicker = false

    private let createTaskUseCase: CreateTaskUseCase

    init(createTaskUseCase: CreateTaskUseCase) {
        self.createTaskUseCase = createTaskUseCase
    }

    // MARK: - Validation
    var isFormValid: Bool {
        !title.isEmpty &&
        !selectedDates.isEmpty &&
        selectedAssignee != nil
    }

    // MARK: - Create Task
    func createTask(businessId: String) async -> Bool {
        guard let assignee = selectedAssignee else { return false }

        let dates = selectedDates
            .compactMap { Calendar.current.date(from: $0) }
            .sorted()

        guard let startDate = dates.first,
              let endDate = dates.last else {
            errorMessage = "Tarih aralığı seçilmedi"
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await createTaskUseCase.execute(
                businessId: businessId,
                title: title,
                description: detail,
                startDate: startDate,
                endDate: endDate,
                assignedToUserId: assignee.userId
            )
            return true
        } catch {
            errorMessage = "Görev oluşturulamadı"
            return false
        }
    }
}
