//
//  MockCreateShiftUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

final class MockCreateShiftUseCase: CreateShiftUseCaseProtocol {

    private(set) var executedBody: CreateShiftRequestDTO?

    func execute(_ body: CreateShiftRequestDTO) async throws {
        executedBody = body
    }
}
