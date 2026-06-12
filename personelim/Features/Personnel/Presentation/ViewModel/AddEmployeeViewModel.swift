import SwiftUI

@MainActor
final class AddEmployeeViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let sendUseCase: SendInvitationUseCaseProtocol

    init(sendUseCase: SendInvitationUseCaseProtocol) {
        self.sendUseCase = sendUseCase
    }

    func send(businessId: String) async {
        errorMessage = nil
        successMessage = nil

        let e = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !e.isEmpty, e.contains("@") else {
            errorMessage = ConstantStrings.invalidEmailError
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let res = try await sendUseCase.execute(
                businessId: businessId,
                email: e,
                message: nil
            )

            successMessage = res.message ??
                ConstantStrings.invitationSuccess

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.invitationSendFailed
            )
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
