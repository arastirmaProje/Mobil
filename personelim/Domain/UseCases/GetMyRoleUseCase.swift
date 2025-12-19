//
//  GetMyRoleUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

protocol GetMyRoleUseCaseProtocol {
    func execute(businessId: String, myUserId: String) async throws -> UserRole
}

final class GetMyRoleUseCase: GetMyRoleUseCaseProtocol {
    private let repo: BusinessMemberRepositoryProtocol

    init(repo: BusinessMemberRepositoryProtocol) {
        self.repo = repo
    }

    func execute(businessId: String, myUserId: String) async throws -> UserRole {
        let members = try await repo.getMembers(businessId: businessId)
        let me = members.first { $0.userId.lowercased() == myUserId.lowercased() }
        return me?.role ?? .default
    }
}
