import Foundation

@MainActor
final class TaskFeedbackViewModel: ObservableObject {

    @Published var feedbackText: String = ""
    @Published var difficulty: Int = 3
    @Published var isSaving = false
    @Published var errorMessage: String?

    let taskId: String
    let activityType: ActivityType
    let finalStatus: String

    private let updateStatusUseCase: UpdateActivityStatusUseCase

    init(
        taskId: String,
        activityType: ActivityType,
        finalStatus: String,
        updateStatusUseCase: UpdateActivityStatusUseCase
    ) {
        self.taskId = taskId
        self.activityType = activityType
        self.finalStatus = finalStatus
        self.updateStatusUseCase = updateStatusUseCase
    }

    var isValid: Bool {
        !feedbackText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    var difficultyText: String {
        switch difficulty {
        case 1:
            return ConstantStrings.difficultyVeryEasy
        case 2:
            return ConstantStrings.difficultyEasy
        case 3:
            return ConstantStrings.difficultyMedium
        case 4:
            return ConstantStrings.difficultyHard
        case 5:
            return ConstantStrings.difficultyVeryHard
        default:
            return ConstantStrings.difficultyMedium
        }
    }

    func submit() async -> Bool {

        guard isValid else {
            errorMessage = ConstantStrings.feedbackRequiredError
            return false
        }

        guard activityType == .task else {
            errorMessage = ConstantStrings.feedbackNotSupportedError
            return false
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            try await updateStatusUseCase.execute(
                activityId: taskId,
                activityType: activityType,
                status: finalStatus,
                thoughts: feedbackText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                difficulty: difficultyText
            )

            return true

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.feedbackSaveFailed
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
