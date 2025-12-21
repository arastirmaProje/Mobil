//
//  AppState.swift
//  personelim
//
//  Created by Tuğberk Acabey on 15.12.2025.
//

import Foundation

@MainActor
final class AppState: ObservableObject {

    @Published private(set) var isLoggedIn: Bool = false

    @Published var userId: String?
    @Published var businessId: String?
    @Published var role: UserRole = .default
    @Published var businessMembers: [BusinessMemberDTO] = []

    init() {
        isLoggedIn = TokenStore.shared.hasValidToken()
    }

    func applyLogin(userId: String, role: UserRole) {
        self.userId = userId
        self.role = role
        self.isLoggedIn = true
    }

    func logout() {
        TokenStore.shared.clear()
        isLoggedIn = false
        userId = nil
        businessId = nil
        role = .default
        businessMembers = []
    }

    func loadRoleIfNeeded(
        authRepository: AuthRepositoryProtocol,
        businessMemberRepository: BusinessMemberRepositoryProtocol
    ) async {
        guard isLoggedIn else { return }

        if userId == nil {
            do {
                let profile = try await authRepository.getProfile()
                userId = profile.id
            } catch {
                return
            }
        }

        guard let businessId, let userId else { return }

        do {
            let members = try await businessMemberRepository.getMembers(businessId: businessId)
            self.businessMembers = members.filter { $0.isActive == true }

            let me = members.first { $0.userId.lowercased() == userId.lowercased() }
            role = me?.role ?? .default
        } catch {
            role = .default
        }
    }

    func loadBusinessMembersIfNeeded(
        repository: BusinessMemberRepositoryProtocol
    ) async {
        guard let businessId else { return }
        guard businessMembers.isEmpty else { return }

        do {
            let members = try await repository.getMembers(businessId: businessId)
            self.businessMembers = members.filter { $0.isActive == true }
        } catch {
            print("❌ Failed to load members:", error)
        }
    }
}
