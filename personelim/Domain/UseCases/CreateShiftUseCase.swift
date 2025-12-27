//
//  CreateShiftUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

final class CreateShiftUseCase: CreateShiftUseCaseProtocol {

    private let repo: ShiftRepositoryProtocol

    init(repo: ShiftRepositoryProtocol) {
        self.repo = repo
    }

    func execute(_ body: CreateShiftRequestDTO) async throws {
        try await repo.createShift(body)
    }
}
