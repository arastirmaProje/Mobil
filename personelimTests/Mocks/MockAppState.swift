//
//  MockAppState.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

@testable import personelim
import XCTest

@MainActor
final class MockAppState: AppState {

    private(set) var didApplyLogin = false

    override func applyLogin(
        userDTO: UserProfileDTO,
        role: UserRole
    ) {
        didApplyLogin = true
    }

    override func bootstrap(
        authRepository: AuthRepositoryProtocol,
        businessRepository: BusinessRepositoryProtocol,
        businessMemberRepository: BusinessMemberRepositoryProtocol
    ) async {
        // no-op (test için boş)
    }
}
