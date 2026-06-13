//
//  DepartmentPerformanceViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import Foundation

@MainActor
final class DepartmentPerformanceViewModel: ObservableObject {

    @Published var report: DepartmentPerformanceResponseDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var reports: [DepartmentReportHistoryDTO] = []
    @Published var isReportsLoading = false
    @Published var selectedReportId: String?

    @Published var startDate: Date =
        Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

    @Published var endDate: Date = Date()

    private let repository: DepartmentRepositoryProtocol

    init(
        repository: DepartmentRepositoryProtocol = DepartmentRepositoryImpl()
    ) {
        self.repository = repository
    }

    func load(
        businessId: String,
        departmentId: String
    ) async {
        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        let s = min(startDate, endDate)
        let e = max(startDate, endDate)

        let request = DepartmentPerformanceRequestDTO(
            businessId: businessId,
            departmentId: departmentId,
            startDate: Self.utcDateOnlyString(from: s),
            endDate: Self.utcDateOnlyString(from: e)
        )

        do {
            report = try await repository.queryDepartmentPerformance(
                request: request
            )

            await loadReports(
                businessId: businessId,
                departmentId: departmentId
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.departmentPerformanceLoadFailed
            )
        }
    }

    func loadReports(
        businessId: String,
        departmentId: String
    ) async {
        isReportsLoading = true

        defer {
            isReportsLoading = false
        }

        do {
            let allReports = try await repository.getDepartmentReports(
                businessId: businessId
            )

            reports = allReports
                .filter { $0.departmentId == departmentId }
                .sorted { lhs, rhs in
                    date(from: lhs.createdAt) > date(from: rhs.createdAt)
                }
        } catch {
            reports = []
        }
    }

    func loadReportDetail(
        reportId: String
    ) async {
        selectedReportId = reportId
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
            report = nil
        }
    }

    func statusText(for score: Double) -> String {
        if score >= 85 {
            return ConstantStrings.departmentPerformanceExcellentStatus
        }

        if score >= 70 {
            return ConstantStrings.departmentPerformanceGoodStatus
        }

        if score >= 50 {
            return ConstantStrings.departmentPerformanceMediumStatus
        }

        return ConstantStrings.departmentPerformanceWeakStatus
    }

    func formattedDateRange(
        start: String,
        end: String
    ) -> String {
        "\(Self.displayDate(from: start)) – \(Self.displayDate(from: end))"
    }

    func scoreProgress(for score: Double) -> Double {
        max(0, min(score / 100, 1))
    }

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

    private static func displayDate(from value: String) -> String {
        let parsedDate = parseDate(from: value)

        guard let parsedDate else {
            return value
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd/MM/yyyy"

        return formatter.string(from: parsedDate)
    }

    private static func parseDate(from value: String) -> Date? {
        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = fractionalFormatter.date(from: value) {
            return date
        }

        let normalFormatter = ISO8601DateFormatter()

        return normalFormatter.date(from: value)
    }

    private func date(from value: String) -> Date {
        Self.parseDate(from: value) ?? .distantPast
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
