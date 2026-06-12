import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {

    // MARK: - Auth / App Status
    @Published private(set) var isLoggedIn: Bool = false
    @Published var isBootstrapping: Bool = false
    @Published var bootstrapError: String?
    @Published var needsCompanyCreation: Bool = false

    // MARK: - User & Business Context
    @Published var userDTO: UserProfileDTO?
    @Published var role: UserRole = .default
    @Published var companyDTO: BusinessDTO?
    @Published var businessMembers: [BusinessMemberDTO] = []
    @Published var activitiesChangeToken: UUID = UUID()

    // MARK: - Derived Properties
    var displayName: String {
        let f = userDTO?.firstName?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? .empty
        let l = userDTO?.lastName?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? .empty

        let full = [f, l]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return full.isEmpty
            ? ConstantStrings.dashPlaceholder
            : full
    }

    var isSubscribed: Bool { companyDTO?.isSubscribed ?? false }
    var businessId: String? { companyDTO?.id }
    var userId: String? { userDTO?.id }

    init() {
        isLoggedIn = TokenStore.shared.hasValidToken()
    }

    func signalActivitiesChanged() {
        activitiesChangeToken = UUID()
    }

    // MARK: - LOGIN
    func applyLogin(userDTO: UserProfileDTO, role: UserRole) {
        self.userDTO = userDTO
        self.role = role
        self.isLoggedIn = true
        self.needsCompanyCreation = false
    }

    // MARK: - LOGOUT
    func logout() {
        TokenStore.shared.clear()
        isLoggedIn = false
        isBootstrapping = false
        bootstrapError = nil
        needsCompanyCreation = false
        userDTO = nil
        role = .default
        companyDTO = nil
        businessMembers = []
    }

    // MARK: - BOOTSTRAP
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
            let profile = try await authRepository.getProfile()
            self.userDTO = profile

            let businesses = try await businessRepository.getBusinesses()

            guard let firstBusiness = businesses.first else {
                role = .default
                companyDTO = nil
                businessMembers = []
                TokenStore.shared.selectedBusinessId = nil
                needsCompanyCreation = true
                return
            }

            needsCompanyCreation = false
            companyDTO = firstBusiness
            TokenStore.shared.selectedBusinessId = firstBusiness.id

            let members = try await businessMemberRepository
                .getMembers(businessId: firstBusiness.id)

            businessMembers = members.filter { $0.isActive ?? false }

            if let me = businessMembers.first(
                where: { $0.userId.lowercased() == profile.id.lowercased() }
            ) {
                role = me.role
            } else {
                role = .default
            }

        } catch {
            bootstrapError = error.localizedDescription
            logout()
        }
    }

    // MARK: - MEMBERS
    func loadBusinessMembersIfNeeded(
        repository: BusinessMemberRepositoryProtocol
    ) async {

        guard let businessId = companyDTO?.id,
              businessMembers.isEmpty else { return }

        do {
            let members = try await repository.getMembers(businessId: businessId)
            businessMembers = members.filter { $0.isActive ?? false }
        } catch {
            print(ConstantStrings.membersLoadFailed, error.localizedDescription)
        }
    }

    func refreshBusinessMembers(
        repository: BusinessMemberRepositoryProtocol
    ) async {

        guard let businessId = companyDTO?.id else { return }

        do {
            let members = try await repository.getMembers(businessId: businessId)
            businessMembers = members.filter { $0.isActive ?? false }
        }   catch {
            logout()
            bootstrapError = ConstantStrings.sessionLoadFailed
        }
    }
}
