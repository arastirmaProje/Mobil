//
//  MockGetPerformanceReportsUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import Foundation
@testable import personelim

final class MockGetPerformanceReportsUseCase: GetPerformanceReportsUseCaseProtocol {

    var result: Result<[PerformanceReportDTO], Error> = .failure(MockError.sample)

    func execute(
        businessId: String,
        employeeUserId: String
    ) async throws -> [PerformanceReportDTO] {
        try result.get()
    }
}
