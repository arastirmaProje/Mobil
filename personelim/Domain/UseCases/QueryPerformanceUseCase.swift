//
//  QueryPerformanceUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

protocol QueryPerformanceUseCaseProtocol {
    func execute(body: PerformanceQueryRequestDTO) async throws -> PerformanceReportDTO
}

struct QueryPerformanceUseCase: QueryPerformanceUseCaseProtocol {
    let repo: PerformanceRepositoryProtocol
    func execute(body: PerformanceQueryRequestDTO) async throws -> PerformanceReportDTO {
        try await repo.queryPerformance(body)
    }
}
