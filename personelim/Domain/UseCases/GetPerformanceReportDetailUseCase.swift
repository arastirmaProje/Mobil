//
//  GetPerformanceReportDetailUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

protocol GetPerformanceReportDetailUseCaseProtocol {
    func execute(reportId: String) async throws -> PerformanceReportDTO
}

struct GetPerformanceReportDetailUseCase: GetPerformanceReportDetailUseCaseProtocol {
    let repo: PerformanceRepositoryProtocol
    func execute(reportId: String) async throws -> PerformanceReportDTO {
        try await repo.getReportDetail(reportId: reportId)
    }
}
