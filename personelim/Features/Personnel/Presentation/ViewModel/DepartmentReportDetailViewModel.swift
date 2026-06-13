import Foundation

@MainActor
final class DepartmentReportDetailViewModel: ObservableObject {

    @Published var report: DepartmentPerformanceResponseDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: DepartmentRepositoryProtocol

    init(
        repository: DepartmentRepositoryProtocol = DepartmentRepositoryImpl()
    ) {
        self.repository = repository
    }

    func load(reportId: String) async {
        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            report = try await repository.getDepartmentReportDetail(
                reportId: reportId
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.departmentPerformanceDetailLoadFailed
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
