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
    @Published var isBootstrapping: Bool = false
    @Published var bootstrapError: String?

    @Published var userId: String?
    @Published var businessId: String?
    @Published var role: UserRole = .default
    @Published var businessMembers: [BusinessMemberDTO] = []
    @Published var firstName: String?
    @Published var lastName: String?

    var displayName: String {
        let f = (firstName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let l = (lastName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let full = [f, l].filter { !$0.isEmpty }.joined(separator: " ")
        return full.isEmpty ? "—" : full
    }

    init() {
        isLoggedIn = TokenStore.shared.hasValidToken()
        businessId = TokenStore.shared.selectedBusinessId
    }

    func applyLogin(userId: String, role: UserRole, businessId: String? = nil) {
        self.userId = userId
        self.role = role
        self.isLoggedIn = true

        if let businessId {
            self.businessId = businessId
            TokenStore.shared.selectedBusinessId = businessId
        }
    }

    func setSelectedBusiness(_ id: String?) {
        businessId = id
        TokenStore.shared.selectedBusinessId = id
    }

    func logout() {
        TokenStore.shared.clear()
        isLoggedIn = false
        isBootstrapping = false
        bootstrapError = nil

        userId = nil
        businessId = nil
        role = .default
        businessMembers = []

        firstName = nil
        lastName = nil
    }

    func bootstrap(
        authRepository: AuthRepositoryProtocol,
        businessRepository: BusinessRepositoryProtocol,
        businessMemberRepository: BusinessMemberRepositoryProtocol
    ) async {
        bootstrapError = nil

        guard TokenStore.shared.hasValidToken() else {
            logout()
            return
        }

        isLoggedIn = true
        isBootstrapping = true
        defer { isBootstrapping = false }

        do {
            if userId == nil {
                let profile = try await authRepository.getProfile()
                userId = profile.id

                firstName = profile.firstName
                lastName = profile.lastName
            }

            if businessId == nil {
                let businesses = try await businessRepository.getBusinesses()
                let firstId = businesses.first?.id
                businessId = firstId
                TokenStore.shared.selectedBusinessId = firstId
            }

            guard let bid = businessId, let uid = userId else {
                role = .default
                businessMembers = []
                return
            }

            let members = try await businessMemberRepository.getMembers(businessId: bid)
            self.businessMembers = members.filter { $0.isActive == true }

            let me = members.first { $0.userId.lowercased() == uid.lowercased() }

            print("🟣 BOOT uid:", uid)
            print("🟣 BOOT bid:", bid)
            print("🟣 BOOT members count:", members.count)
            print("🟣 BOOT me userId:", me?.userId ?? "nil")
            print("🟣 BOOT me role raw:", me?.role.rawValue ?? "nil")
            print("🟣 BOOT final role BEFORE assign:", role)

            role = me?.role ?? .default

            print("🟢 BOOT final role AFTER assign:", role)

        } catch {
            bootstrapError = error.localizedDescription
            logout()
        }
    }

    func loadRoleIfNeeded(
        authRepository: AuthRepositoryProtocol,
        businessRepository: BusinessRepositoryProtocol,
        businessMemberRepository: BusinessMemberRepositoryProtocol
    ) async {
        guard TokenStore.shared.hasValidToken() else { return }
        isLoggedIn = true

        do {
            if userId == nil {
                let profile = try await authRepository.getProfile()
                userId = profile.id

                firstName = profile.firstName
                lastName = profile.lastName
            }

            if businessId == nil {
                let businesses = try await businessRepository.getBusinesses()
                businessId = businesses.first?.id
                TokenStore.shared.selectedBusinessId = businessId
            }

            guard let bid = businessId, let uid = userId else { return }

            let members = try await businessMemberRepository.getMembers(businessId: bid)
            self.businessMembers = members.filter { $0.isActive == true }

            let me = members.first { $0.userId.lowercased() == uid.lowercased() }
            role = me?.role ?? .default

        } catch {
            role = .default
        }
    }

    func loadBusinessMembersIfNeeded(repository: BusinessMemberRepositoryProtocol) async {
        guard let businessId else { return }
        guard businessMembers.isEmpty else { return }

        do {
            let members = try await repository.getMembers(businessId: businessId)
            self.businessMembers = members.filter { $0.isActive == true }
        } catch {
            print("Failed to load members:", error)
        }
    }

    func refreshBusinessMembers(repository: BusinessMemberRepositoryProtocol) async {
        guard let businessId else { return }
        do {
            let members = try await repository.getMembers(businessId: businessId)
            self.businessMembers = members.filter { $0.isActive == true }
        } catch {
            print("Failed to refresh members:", error)
        }
    }
}
