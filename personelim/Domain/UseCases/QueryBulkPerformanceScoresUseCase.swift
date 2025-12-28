//
//  QueryBulkPerformanceScoresUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 28.12.2025.
//

import Foundation

protocol QueryBulkPerformanceScoresUseCaseProtocol {
    func execute(businessId: String, start: Date, end: Date) async throws -> [PerformanceBulkScoreItemDTO]
}

final class QueryBulkPerformanceScoresUseCase: QueryBulkPerformanceScoresUseCaseProtocol {

    private let repo: PerformanceRepositoryProtocol

    init(repo: PerformanceRepositoryProtocol) {
        self.repo = repo
    }

    func execute(businessId: String, start: Date, end: Date) async throws -> [PerformanceBulkScoreItemDTO] {

        let req = PerformanceBulkQueryRequestDTO(
            businessId: businessId,
            startDate: Self.isoString(start),
            endDate: Self.isoString(end)
        )

        let res = try await repo.bulkQueryScores(request: req)
        return res.data ?? []
    }

    private static func isoString(_ date: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: date)
    }
}
