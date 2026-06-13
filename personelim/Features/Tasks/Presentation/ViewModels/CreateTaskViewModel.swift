import Foundation

@MainActor
final class CreateTaskViewModel: ObservableObject {

    @Published var title: String = ""
    @Published var detail: String = ""
    @Published var activityType: ActivityType = .meeting
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var selectedAssignees: Set<String> = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showAssigneePicker = false

    private let createActivityUseCase: CreateActivityUseCase

    init(createActivityUseCase: CreateActivityUseCase) {
        self.createActivityUseCase = createActivityUseCase
    }

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        startDate != nil &&
        endDate != nil &&
        (activityType != .task || !selectedAssignees.isEmpty)
    }

    func createTask(businessId: String) async -> Bool {
        guard let startDate,
              let endDate else {
            errorMessage = ConstantStrings.dateRangeNotSelectedError
            return false
        }

        let normalizedStartDate = Calendar.current.startOfDay(
            for: min(startDate, endDate)
        )

        let normalizedEndDate = Self.endOfDay(
            max(startDate, endDate)
        )

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            if activityType == .task {
                for userId in selectedAssignees {
                    try await createActivityUseCase.execute(
                        businessId: businessId,
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        description: detail.trimmingCharacters(in: .whitespacesAndNewlines),
                        startDate: normalizedStartDate,
                        endDate: normalizedEndDate,
                        assignedToUserId: userId,
                        activityType: activityType
                    )
                }
            } else {
                try await createActivityUseCase.execute(
                    businessId: businessId,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: detail.trimmingCharacters(in: .whitespacesAndNewlines),
                    startDate: normalizedStartDate,
                    endDate: normalizedEndDate,
                    assignedToUserId: "",
                    activityType: activityType
                )
            }

            return true

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.createActivityFailed
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
    
    private static func endOfDay(_ date: Date) -> Date {
        Calendar.current.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: date
        ) ?? date
    }
}

