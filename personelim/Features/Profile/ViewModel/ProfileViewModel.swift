import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - State
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var employeeUI: EmployeeProfileUI?
    @Published var managerUI: ManagerProfileUI?

    private let authRepo: AuthRepositoryProtocol
    private let memberRepo: BusinessMemberRepositoryProtocol
    private let businessRepo: BusinessRepositoryProtocol
    private let leaveRepo: LeaveRepositoryProtocol

    private var loadTask: Task<Void, Never>?

    // MARK: - Init
    init(
        authRepo: AuthRepositoryProtocol = AuthRepositoryImpl(network: NetworkManager()),
        memberRepo: BusinessMemberRepositoryProtocol,
        businessRepo: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager()),
        leaveRepo: LeaveRepositoryProtocol = LeaveRepositoryImpl(network: NetworkManager())
    ) {
        self.authRepo = authRepo
        self.memberRepo = memberRepo
        self.businessRepo = businessRepo
        self.leaveRepo = leaveRepo
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
                        fullName: userDTO.fullName ?? "\(userDTO.firstName ?? "") \(userDTO.lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines),
                        position: nil,
                        salaryText: nil,
                        tcIdentityNumber: nil,
                        email: userDTO.email ?? "",
                        imageUrl: userDTO.imageUrl,
                        cvFiles: [],
                        documentFiles: [],
                        remainingLeaveDaysText: "0"
                    )
                    self.employeeUI = employee
                    return
                }
                appState.companyDTO = businessDTO

                let businessId = businessDTO.id
                let members = try await memberRepo.getMembers(businessId: businessId)
                let activeMembers = members.filter { $0.isActive ?? false }
                appState.businessMembers = activeMembers
                let me = activeMembers.first { $0.userId.lowercased() == userDTO.id.lowercased() }
                let role = me?.role ?? .default
                appState.role = role

                var remainingLeaveText = "0"
                if let me {
                    do {
                        let leaves = try await leaveRepo.getMyLeaves(businessId: businessId)
                        let total = leaves.reduce(0) { $0 + $1.dayCount }
                        remainingLeaveText = "\(total)"
                    } catch {
                        print("⚠️ Leave fetch failed:", error.localizedDescription)
                    }
                }

                var cvFiles: [BusinessMemberDocumentDTO] = []
                var documentFiles: [BusinessMemberDocumentDTO] = []

                if let me {
                    let detail = try await memberRepo.getMember(memberId: me.id)
                    let docs = detail.documents ?? []
                    cvFiles = docs.filter { $0.documentType.uppercased() == "CV" }
                    documentFiles = docs.filter { $0.documentType.uppercased() != "CV" }
                }

                let employee = EmployeeProfileUI(
                    fullName: me?.fullName ?? userDTO.fullName ?? "\(userDTO.firstName ?? "") \(userDTO.lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines),
                    position: me?.position,
                    salaryText: me?.salary.map { "\($0) TL" },
                    tcIdentityNumber: me?.tcIdentityNumber,
                    email: userDTO.email ?? "",
                    imageUrl: userDTO.imageUrl,
                    cvFiles: cvFiles,
                    documentFiles: documentFiles,
                    remainingLeaveDaysText: remainingLeaveText
                )

                let offices: [OfficeUI] = (businessDTO.offices?.enumerated().map { idx, o in
                    OfficeUI(
                        id: o.id ?? "office-\(idx)",
                        name: o.officeName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Ofis \(idx + 1)",
                        latitude: o.latitude,
                        longitude: o.longitude
                    )
                }) ?? [
                    OfficeUI(
                        id: "office-1",
                        name: businessDTO.locationName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Merkez Ofis",
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
                self.errorMessage = error.localizedDescription
            }
        }

        await loadTask?.value
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
