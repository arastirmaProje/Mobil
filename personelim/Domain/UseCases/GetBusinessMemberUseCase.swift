//
//  GetBusinessMemberUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

protocol GetBusinessMemberUseCaseProtocol {
    func execute(memberId: String) async throws -> BusinessMemberDTO
}

struct GetBusinessMemberUseCase: GetBusinessMemberUseCaseProtocol {
    let repo: BusinessMemberRepositoryProtocol
    func execute(memberId: String) async throws -> BusinessMemberDTO {
        try await repo.getMember(memberId: memberId)
    }
}
