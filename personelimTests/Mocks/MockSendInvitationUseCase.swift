//
//  MockSendInvitationUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

final class MockSendInvitationUseCase: SendInvitationUseCaseProtocol {

    var result: Result<SendInvitationResponseDTO, Error>?

    private(set) var receivedBusinessId: String?
    private(set) var receivedEmail: String?

    func execute(
        businessId: String,
        email: String,
        message: String?
    ) async throws -> SendInvitationResponseDTO {

        receivedBusinessId = businessId
        receivedEmail = email

        if let result {
            switch result {
            case .success(let dto):
                return dto
            case .failure(let error):
                throw error
            }
        }

        fatalError("Mock result not set")
    }
}
