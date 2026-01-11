//
//  MockResetPasswordUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

@testable import personelim
import XCTest

final class MockResetPasswordUseCase: ResetPasswordUseCaseProtocol {

    var result: Result<Bool, Error>?

    func execute(
        email: String,
        code: String,
        newPassword: String,
        confirmPassword: String
    ) async throws -> Bool {
        return try result!.get()
    }
}
