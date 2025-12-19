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
    }

    func loadRoleIfNeeded(
        authRepository: AuthRepositoryProtocol,
        businessMemberRepository: BusinessMemberRepositoryProtocol
    ) async {
        guard isLoggedIn else { return }

        if role != .default { return }

        if userId == nil {
            do {
                let profile = try await authRepository.getProfile()
                userId = profile.id
            } catch {
                role = .default
                return
            }
        }

        guard let businessId, let userId else {
            role = .default
            return
        }

        do {
            let members = try await businessMemberRepository.getMembers(businessId: businessId)
            let me = members.first { $0.userId.lowercased() == userId.lowercased() }
            role = me?.role ?? .default
        } catch {
            role = .default
        }
    }
}
