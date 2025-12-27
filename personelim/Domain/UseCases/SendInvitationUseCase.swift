//
//  SendInvitationUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

struct SendInvitationUseCase: SendInvitationUseCaseProtocol {
    let repo: InvitationRepositoryProtocol
    func execute(businessId: String, email: String, message: String?) async throws -> SendInvitationResponseDTO {
        try await repo.sendInvitation(businessId: businessId, email: email, message: message)
    }
}
