import Foundation

@MainActor
final class PerformanceQueryViewModel: ObservableObject {

    @Published var startDate: Date =
        Calendar.current.date(
            byAdding: .day,
            value: -7,
            to: Date()
        ) ?? Date()

    @Published var endDate: Date = Date()

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let queryUseCase: QueryPerformanceUseCaseProtocol

    init(
        queryUseCase: QueryPerformanceUseCaseProtocol
    ) {
        self.queryUseCase = queryUseCase
    }

    func submit(
        businessId: String,
        employeeUserId: String
    ) async -> PerformanceReportDTO? {

        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        let s = min(startDate, endDate)
        let e = max(startDate, endDate)

        do {
            let body = PerformanceQueryRequestDTO(
                businessId: businessId,
                employeeUserId: employeeUserId,
                startDate: Self.utcDateOnlyString(from: s),
                endDate: Self.utcDateOnlyString(from: e)
            )

            return try await queryUseCase.execute(
                body: body
            )

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.performanceReportCreateFailed
            )

            return nil
        }
    }

    // MARK: - Date Formatter

    private static func utcDateOnlyString(from date: Date) -> String {
        let calendar = Calendar.current

        let components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        let year = components.year ?? 1970
        let month = components.month ?? 1
        let day = components.day ?? 1

        return String(
            format: "%04d-%02d-%02dT00:00:00.000Z",
            year,
            month,
            day
        )
    }

    // MARK: - Error

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
