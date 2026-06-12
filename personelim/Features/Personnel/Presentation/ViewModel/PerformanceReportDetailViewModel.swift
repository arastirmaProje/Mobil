import Foundation

@MainActor
final class PerformanceReportDetailViewModel: ObservableObject {

    @Published var report: PerformanceReportDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let detailUseCase: GetPerformanceReportDetailUseCaseProtocol

    init(
        detailUseCase: GetPerformanceReportDetailUseCaseProtocol
    ) {
        self.detailUseCase = detailUseCase
    }

    func load(reportId: String) async {
        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            report = try await detailUseCase.execute(
                reportId: reportId
            )

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.performanceReportLoadFailed
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
