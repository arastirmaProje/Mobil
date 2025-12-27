//
//  DeleteBusinessMemberUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

struct DeleteBusinessMemberUseCase: DeleteBusinessMemberUseCaseProtocol {
    let repo: BusinessMemberRepositoryProtocol
    func execute(memberId: String) async throws {
        _ = try await repo.deleteMember(memberId: memberId)
    }
}
