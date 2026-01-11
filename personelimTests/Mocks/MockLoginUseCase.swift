//
//  MockLoginUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

@testable import personelim
import XCTest

final class MockLoginUseCase: LoginUseCaseProtocol {

    var result: Result<AuthUserEntity, Error>!

    func execute(email: String, password: String) async throws -> AuthUserEntity {
        return try result.get()
    }
}
