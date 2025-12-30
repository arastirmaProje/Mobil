//
//  CreateLeaveViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 30.12.2025.
//

import Foundation

@MainActor
final class CreateLeaveViewModel: ObservableObject {

    // MARK: - Published
    @Published var selectedDates: Set<DateComponents> = []
    @Published var title: String = ""
    @Published var description: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let businessId: String
    private let repo: LeaveRepositoryProtocol

    // MARK: - Init
    init(
        businessId: String,
        repo: LeaveRepositoryProtocol
    ) {
        self.businessId = businessId
        self.repo = repo
    }

    // MARK: - Validation
    var isFormValid: Bool {
        !selectedDates.isEmpty &&
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Action
    func createLeave() async -> Bool {
        guard isFormValid else { return false }

        isLoading = true
        defer { isLoading = false }

        let dates = selectedDates
            .compactMap { Calendar.current.date(from: $0) }
            .sorted()

        guard let start = dates.first,
              let end = dates.last else {
            errorMessage = "Geçersiz tarih aralığı"
            return false
        }

        do {
            try await repo.createLeave(
                businessId: businessId,
                title: title,
                description: description,
                startDate: start,
                endDate: end
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
