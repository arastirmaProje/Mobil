//
//  PerformanceRepositoryProtocol.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

protocol PerformanceRepositoryProtocol {
    func queryPerformance(_ body: PerformanceQueryRequestDTO) async throws -> PerformanceReportDTO
    func getReports(businessId: String, employeeUserId: String) async throws -> [PerformanceReportDTO]
    func getReportDetail(reportId: String) async throws -> PerformanceReportDTO
    func bulkQueryScores(request: PerformanceBulkQueryRequestDTO) async throws -> ServiceResponse<PerformanceBulkScoreResponseDTO>
}
