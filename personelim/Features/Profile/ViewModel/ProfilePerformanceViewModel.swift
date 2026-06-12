import SwiftUI

@MainActor
final class ProfilePerformanceViewModel: ObservableObject {

    @Published var reports: [PerformanceReportDTO] = []
    @Published var isLoading = false
    @Published var error: String?

    private let getReportsUseCase: GetPerformanceReportsUseCaseProtocol

    init(
        getReportsUseCase: GetPerformanceReportsUseCaseProtocol
    ) {
        self.getReportsUseCase = getReportsUseCase
    }

    func load(
        businessId: String,
        employeeUserId: String
    ) async {
        error = nil
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            reports = try await getReportsUseCase.execute(
                businessId: businessId,
                employeeUserId: employeeUserId
            )
        } catch {
            self.error = userMessage(
                from: error,
                fallback: ConstantStrings.reportsLoadFailed
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
