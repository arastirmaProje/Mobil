//
//  UpdateBusinessMemberUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

struct UpdateBusinessMemberUseCase: UpdateBusinessMemberUseCaseProtocol {

    let repo: BusinessMemberRepositoryProtocol

    func execute(
        memberId: String,
        body: UpdateBusinessMemberRequestDTO
    ) async throws {
        try await repo.updateMember(
            memberId: memberId,
            request: body
        )
    }
}
