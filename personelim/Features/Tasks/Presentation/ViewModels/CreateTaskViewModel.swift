import Foundation

@MainActor
final class CreateTaskViewModel: ObservableObject {

    @Published var title: String = ""
    @Published var detail: String = ""
    @Published var selectedDates: Set<DateComponents> = []
    @Published var selectedAssignees: Set<String> = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showAssigneePicker = false

    private let createTaskUseCase: CreateTaskUseCase

    init(createTaskUseCase: CreateTaskUseCase) {
        self.createTaskUseCase = createTaskUseCase
    }

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedDates.isEmpty &&
        !selectedAssignees.isEmpty
    }

    func createTask(businessId: String) async -> Bool {

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
            for userId in selectedAssignees {

                try await createTaskUseCase.execute(
                    businessId: businessId,
                    title: title,
                    description: detail,
                    startDate: startDate,
                    endDate: endDate,
                    assignedToUserId: userId
                )
            }

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
