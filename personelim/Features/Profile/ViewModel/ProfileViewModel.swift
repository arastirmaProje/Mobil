import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - State

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var employeeUI: EmployeeProfileUI?
    @Published var managerUI: ManagerProfileUI?

    @Published var isLoggingOut = false
    @Published var logoutErrorMessage: String?

    @Published var isUnsubscribing = false
    @Published var unsubscribeErrorMessage: String?

    private let authRepo: AuthRepositoryProtocol
    private let memberRepo: BusinessMemberRepositoryProtocol
    private let businessRepo: BusinessRepositoryProtocol
    private let leaveRepo: LeaveRepositoryProtocol
    private let unsubscribeUseCase: UnsubscribeBusinessUseCaseProtocol

    private var loadTask: Task<Void, Never>?

    // MARK: - Init

    init(
        authRepo: AuthRepositoryProtocol = AuthRepositoryImpl(network: NetworkManager()),
        memberRepo: BusinessMemberRepositoryProtocol,
        businessRepo: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager()),
        leaveRepo: LeaveRepositoryProtocol = LeaveRepositoryImpl(network: NetworkManager()),
        unsubscribeUseCase: UnsubscribeBusinessUseCaseProtocol = UnsubscribeBusinessUseCase(
            repository: BusinessRepositoryImpl(
                networkManager: NetworkManager()
            )
        )
    ) {
        self.authRepo = authRepo
        self.memberRepo = memberRepo
        self.businessRepo = businessRepo
        self.leaveRepo = leaveRepo
        self.unsubscribeUseCase = unsubscribeUseCase
    }

    // MARK: - Logout

    func logout(appState: AppState) async {
        isLoggingOut = true
        logoutErrorMessage = nil

        defer {
            isLoggingOut = false
        }

        do {
            try await authRepo.logout()
            appState.logout()
        } catch {
            logoutErrorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.logoutFailed
            )
        }
    }

    // MARK: - Unsubscribe

    func unsubscribeBusiness(
        businessId: String
    ) async -> Bool {
        isUnsubscribing = true
        unsubscribeErrorMessage = nil
        errorMessage = nil

        defer {
            isUnsubscribing = false
        }

        do {
            try await unsubscribeUseCase.execute(
                businessId: businessId
            )

            return true

        } catch {
            let message = userMessage(
                from: error,
                fallback: error.localizedDescription
            )

            unsubscribeErrorMessage = message
            errorMessage = message
            return false
        }
    }

    // MARK: - Load Profile

    func loadProfile(appState: AppState) async {
        if loadTask != nil { return }

        isLoading = true
        errorMessage = nil
        employeeUI = nil
        managerUI = nil

        loadTask = Task {
            defer {
                Task { @MainActor in
                    self.isLoading = false
                    self.loadTask = nil
                }
            }

            do {
                let userDTO = try await authRepo.getProfile()
                appState.userDTO = userDTO

                let businesses = try await businessRepo.getBusinesses()

                guard let businessDTO = businesses.first else {
                    let employee = EmployeeProfileUI(
                        fullName: userDTO.fullName
                            ?? "\(userDTO.firstName ?? "") \(userDTO.lastName ?? "")"
                                .trimmingCharacters(in: .whitespacesAndNewlines),
                        position: nil,
                        salaryText: nil,
                        tcIdentityNumber: nil,
                        email: userDTO.email ?? "",
                        imageUrl: userDTO.imageUrl,
                        cvFiles: [],
                        documentFiles: [],
                        remainingLeaveDaysText: "0",
                        leaveRequests: []
                    )

                    self.employeeUI = employee
                    return
                }

                appState.companyDTO = businessDTO

                let businessId = businessDTO.id

                let members = try await memberRepo.getMembers(
                    businessId: businessId
                )

                let activeMembers = members.filter { $0.isActive ?? false }
                appState.businessMembers = activeMembers

                let me = activeMembers.first {
                    $0.userId.lowercased() == userDTO.id.lowercased()
                }

                let role = me?.role ?? .default
                appState.role = role

                var remainingLeaveText = "0"
                var leaveRequests: [LeaveEntity] = []

                if me != nil {
                    do {
                        let leaves = try await leaveRepo.getMyLeaves(
                            businessId: businessId
                        )

                        leaveRequests = leaves.sorted {
                            $0.startDate > $1.startDate
                        }

                        let approvedLeaves = leaves.filter {
                            $0.status == .approved
                        }

                        let total = approvedLeaves.reduce(0) {
                            $0 + $1.dayCount
                        }

                        remainingLeaveText = "\(total)"
                    } catch {
                        print("⚠️ Leave fetch failed:", error)
                    }
                }

                var cvFiles: [BusinessMemberDocumentDTO] = []
                var documentFiles: [BusinessMemberDocumentDTO] = []

                if let me {
                    let detail = try await memberRepo.getMember(
                        memberId: me.id
                    )

                    let docs = detail.documents ?? []

                    cvFiles = docs.filter {
                        $0.documentType.uppercased() == "CV"
                    }

                    documentFiles = docs.filter {
                        $0.documentType.uppercased() != "CV"
                    }
                }

                let employee = EmployeeProfileUI(
                    fullName: me?.fullName
                        ?? userDTO.fullName
                        ?? "\(userDTO.firstName ?? "") \(userDTO.lastName ?? "")"
                            .trimmingCharacters(in: .whitespacesAndNewlines),
                    position: me?.position,
                    salaryText: me?.salary.map { "\($0) TL" },
                    tcIdentityNumber: me?.tcIdentityNumber,
                    email: userDTO.email ?? "",
                    imageUrl: userDTO.imageUrl,
                    cvFiles: cvFiles,
                    documentFiles: documentFiles,
                    remainingLeaveDaysText: remainingLeaveText,
                    leaveRequests: leaveRequests
                )

                let offices: [OfficeUI] = (
                    businessDTO.offices?.enumerated().map { idx, o in
                        OfficeUI(
                            id: o.id ?? "office-\(idx)",
                            name: o.officeName?
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                ?? String(
                                    format: ConstantStrings.officeDefaultNameFormat,
                                    idx + 1
                                ),
                            latitude: o.latitude,
                            longitude: o.longitude
                        )
                    }
                ) ?? [
                    OfficeUI(
                        id: "office-1",
                        name: businessDTO.locationName?
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            ?? ConstantStrings.mainOfficeTitle,
                        latitude: businessDTO.latitude,
                        longitude: businessDTO.longitude
                    )
                ]

                if role.canSeePersonnelTab {
                    self.managerUI = ManagerProfileUI(
                        companyName: businessDTO.name,
                        companyDescription: businessDTO.description,
                        companyEmail: userDTO.email ?? "",
                        offices: offices,
                        companyImageUrl: businessDTO.imageUrl,
                        employee: employee,
                        companyPhoneNumber: businessDTO.phoneNumber,
                        companyAddress: businessDTO.address,
                        companyProvinceName: businessDTO.provinceName,
                        companyDistrictName: businessDTO.districtName,
                        companyLocationName: businessDTO.locationName
                    )
                } else {
                    self.employeeUI = employee
                }

            } catch {
                self.errorMessage = self.userMessage(
                    from: error,
                    fallback: ConstantStrings.profileNotRetrivied
                )
            }
        }

        await loadTask?.value
    }

    // MARK: - Helpers

    private func userMessage(
        from error: Error,
        fallback: String
    ) -> String {
        if case let RepositoryError.api(message) = error {
            return message
        }

        return fallback
    }
}

// MARK: - Convenience

@MainActor
extension ProfileViewModel {

    func loadIfNeeded(appState: AppState) async {
        guard employeeUI == nil && managerUI == nil else { return }
        await loadProfile(appState: appState)
    }

    func reload(appState: AppState) async {
        await loadProfile(appState: appState)
    }
}
