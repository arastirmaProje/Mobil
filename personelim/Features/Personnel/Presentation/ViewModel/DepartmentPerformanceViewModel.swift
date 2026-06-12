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
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.departmentPerformanceLoadFailed
            )
        }
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
