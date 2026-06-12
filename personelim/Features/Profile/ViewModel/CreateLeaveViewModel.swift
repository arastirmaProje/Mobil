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
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Action

    func createLeave() async -> Bool {

        guard isFormValid else {
            errorMessage = ConstantStrings.leaveFormValidationError
            return false
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        let dates = selectedDates
            .compactMap { Calendar.current.date(from: $0) }
            .sorted()

        guard let start = dates.first,
              let end = dates.last else {
            errorMessage = ConstantStrings.invalidDateRangeError
            return false
        }

        do {
            try await repo.createLeave(
                businessId: businessId,
                title: title.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                description: description.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                startDate: start,
                endDate: end
            )

            return true

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.leaveCreateFailed
            )

            return false
        }
    }

    private func userMessage(
        from error: Error,
        fallback: String
    ) -> String {

        if case let RepositoryError.api(message) = error {
            return message
        }

        return fallback
    }
}
