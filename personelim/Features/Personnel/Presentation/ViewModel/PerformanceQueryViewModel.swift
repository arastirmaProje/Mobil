//
//  PerformanceQueryViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

@MainActor
final class PerformanceQueryViewModel: ObservableObject {

    @Published var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @Published var endDate: Date = Date()

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let queryUseCase: QueryPerformanceUseCaseProtocol

    init(queryUseCase: QueryPerformanceUseCaseProtocol) {
        self.queryUseCase = queryUseCase
    }

    func submit(businessId: String, employeeUserId: String) async -> PerformanceReportDTO? {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let s = min(startDate, endDate)
        let e = max(startDate, endDate)

        do {
            let body = PerformanceQueryRequestDTO(
                businessId: businessId,
                employeeUserId: employeeUserId,
                startDate: ISODate.string(from: s),
                endDate: ISODate.string(from: e)
            )
            return try await queryUseCase.execute(body: body)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
