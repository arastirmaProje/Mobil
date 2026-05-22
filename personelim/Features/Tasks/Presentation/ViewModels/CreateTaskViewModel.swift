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
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
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

        let normalizedStartDate = min(startDate, endDate)
        let normalizedEndDate = max(startDate, endDate)

        isLoading = true
        defer { isLoading = false }

        do {
            if activityType == .task {
                for userId in selectedAssignees {
                    try await createActivityUseCase.execute(
                        businessId: businessId,
                        title: title,
                        description: detail,
                        startDate: normalizedStartDate,
                        endDate: normalizedEndDate,
                        assignedToUserId: userId,
                        activityType: activityType
                    )
                }
            } else {
                try await createActivityUseCase.execute(
                    businessId: businessId,
                    title: title,
                    description: detail,
                    startDate: normalizedStartDate,
                    endDate: normalizedEndDate,
                    assignedToUserId: "",
                    activityType: activityType
                )
            }

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
