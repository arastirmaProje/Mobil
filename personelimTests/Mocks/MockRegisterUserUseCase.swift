//
//  MockRegisterUserUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

final class MockRegisterUserUseCase: RegisterUserUseCaseProtocol {

    var result: Result<AuthUserEntity, Error>?

    func execute(_ user: RegisterUserEntity) async throws -> AuthUserEntity {
        return try result!.get()
    }
}
