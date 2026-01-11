//
//  MockQueryPerformanceUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

final class MockQueryPerformanceUseCase: QueryPerformanceUseCaseProtocol {

    var receivedBody: PerformanceQueryRequestDTO?
    var result: Result<PerformanceReportDTO, Error>?

    func execute(body: PerformanceQueryRequestDTO) async throws -> PerformanceReportDTO {
        receivedBody = body
        switch result {
        case .success(let dto):
            return dto
        case .failure(let error):
            throw error
        case .none:
            fatalError("Mock result not set")
        }
    }
}
