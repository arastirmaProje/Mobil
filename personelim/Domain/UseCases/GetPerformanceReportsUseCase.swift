//
//  GetPerformanceReportsUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

protocol GetPerformanceReportsUseCaseProtocol {
    func execute(businessId: String, employeeUserId: String) async throws -> [PerformanceReportDTO]
}

struct GetPerformanceReportsUseCase: GetPerformanceReportsUseCaseProtocol {
    let repo: PerformanceRepositoryProtocol
    func execute(businessId: String, employeeUserId: String) async throws -> [PerformanceReportDTO] {
        try await repo.getReports(businessId: businessId, employeeUserId: employeeUserId)
    }
}
