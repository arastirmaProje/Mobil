import Foundation

@MainActor
final class CreateTaskViewModel: ObservableObject {

    @Published var title: String = ""
    @Published var detail: String = ""
    @Published var activityType: ActivityType = .meeting
    @Published var selectedDates: Set<DateComponents> = []
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
        !selectedDates.isEmpty &&
        (activityType != .task || !selectedAssignees.isEmpty)
    }

    func createTask(businessId: String) async -> Bool {

        let dates = selectedDates
            .compactMap { Calendar.current.date(from: $0) }
            .sorted()

        guard let startDate = dates.first,
              let endDate = dates.last else {
            errorMessage = ConstantStrings.dateRangeNotSelectedError
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if activityType == .task {
                for userId in selectedAssignees {
                    try await createActivityUseCase.execute(
                        businessId: businessId,
                        title: title,
                        description: detail,
                        startDate: startDate,
                        endDate: endDate,
                        assignedToUserId: userId,
                        activityType: activityType
                    )
                }
            } else {
                try await createActivityUseCase.execute(
                    businessId: businessId,
                    title: title,
                    description: detail,
                    startDate: startDate,
                    endDate: endDate,
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
