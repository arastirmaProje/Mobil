import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var employeeUI: EmployeeProfileUI?
    @Published var managerUI: ManagerProfileUI?

    private let authRepo: AuthRepositoryProtocol
    private let memberRepo: BusinessMemberRepositoryProtocol
    private let businessRepo: BusinessRepositoryProtocol

    private var didLoadOnce = false
    private var loadTask: Task<Void, Never>?

    init(
        authRepo: AuthRepositoryProtocol = AuthRepositoryImpl(network: NetworkManager()),
        memberRepo: BusinessMemberRepositoryProtocol = BusinessMemberRepositoryImpl(network: NetworkManager()),
        businessRepo: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager())
    ) {
        self.authRepo = authRepo
        self.memberRepo = memberRepo
        self.businessRepo = businessRepo
    }

    func loadIfNeeded(appState: AppState) async {
        guard !didLoadOnce else { return }
        await loadInternal(appState: appState, force: false)
    }

    func reload(appState: AppState) async {
        await loadInternal(appState: appState, force: true)
    }

    private func loadInternal(appState: AppState, force: Bool) async {

        if loadTask != nil { return }

        if didLoadOnce && !force { return }

        isLoading = true
        errorMessage = nil

        loadTask = Task {
            defer {
                Task { @MainActor in
                    self.isLoading = false
                    self.loadTask = nil
                    self.didLoadOnce = true
                }
            }

            do {
                let auth = try await authRepo.getProfile()
                appState.userId = auth.id

                let myNameFromAuth: String = {
                    if let full = auth.fullName?.trimmingCharacters(in: .whitespacesAndNewlines), !full.isEmpty {
                        return full
                    }
                    let f = (auth.firstName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let l = (auth.lastName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    return "\(f) \(l)".trimmingCharacters(in: .whitespacesAndNewlines)
                }()

                let businesses = try await businessRepo.getBusinesses()
                guard let business = businesses.first else {
                    self.employeeUI = EmployeeProfileUI(
                        fullName: myNameFromAuth,
                        position: nil,
                        salaryText: nil,
                        tcIdentityNumber: nil,
                        email: auth.email,
                        imageUrl: auth.imageUrl,
                        cvFiles: [],
                        documentFiles: [],
                        remainingLeaveDaysText: "4"
                    )
                    self.managerUI = nil
                    return
                }

                appState.businessId = business.id
                let businessId = business.id

                let members: [BusinessMemberDTO]
                if force == true {
                    let fetched = try await memberRepo.getMembers(businessId: businessId)
                    let active = fetched.filter { $0.isActive == true }
                    appState.businessMembers = active
                    members = active
                } else if !appState.businessMembers.isEmpty,
                          (appState.businessId?.lowercased() == businessId.lowercased()) {
                    members = appState.businessMembers
                } else {
                    let fetched = try await memberRepo.getMembers(businessId: businessId)
                    let active = fetched.filter { $0.isActive == true }
                    appState.businessMembers = active
                    members = active
                }

                let me = members.first { $0.userId.lowercased() == auth.id.lowercased() }
                appState.role = me?.role ?? .default

                let salaryText: String? = {
                    guard let s = me?.salary else { return nil }
                    return "\(Int(s))TL"
                }()

                var cvFiles: [BusinessMemberDocumentDTO] = []
                var documentFiles: [BusinessMemberDocumentDTO] = []
                var tcIdentityNumber: String? = nil

                if let me {
                    let detail = try await memberRepo.getMember(memberId: me.id)
                    let docs = detail.documents ?? []
                    cvFiles = docs.filter { $0.documentType.uppercased() == "CV" }
                    documentFiles = docs.filter { $0.documentType.uppercased() != "CV" }
                    tcIdentityNumber = detail.tcIdentityNumber ?? me.tcIdentityNumber
                }

                let employee = EmployeeProfileUI(
                    fullName: myNameFromAuth,
                    position: me?.position,
                    salaryText: salaryText,
                    tcIdentityNumber: tcIdentityNumber ?? me?.tcIdentityNumber,
                    email: auth.email,
                    imageUrl: auth.imageUrl,
                    cvFiles: cvFiles,
                    documentFiles: documentFiles,
                    remainingLeaveDaysText: "4"
                )

                let officesUI: [OfficeUI] = {
                    if let offices = business.offices, !offices.isEmpty {
                        return offices.enumerated().map { idx, o in
                            let n = (o.officeName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                            return OfficeUI(
                                id: o.id ?? "office-\(idx)",
                                name: n.isEmpty ? "Ofis \(idx + 1)" : n,
                                latitude: (o.latitude == 0 ? nil : o.latitude),
                                longitude: (o.longitude == 0 ? nil : o.longitude)
                            )
                        }
                    }

                    let name = (business.locationName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    return [
                        OfficeUI(
                            id: "office-1",
                            name: name.isEmpty ? "Ofis 1" : name,
                            latitude: (business.latitude == 0 ? nil : business.latitude),
                            longitude: (business.longitude == 0 ? nil : business.longitude)
                        )
                    ]
                }()

                if appState.role.canSeePersonnelTab {
                    self.managerUI = ManagerProfileUI(
                        companyName: business.name,
                        companyDescription: business.description,
                        companyEmail: auth.email,
                        offices: officesUI,
                        companyImageUrl: business.imageUrl,
                        employee: employee,
                        companyPhoneNumber: business.phoneNumber,
                        companyAddress: business.address,
                        companyProvinceName: business.provinceName,
                        companyDistrictName: business.districtName,
                        companyLocationName: business.locationName
                    )
                    self.employeeUI = nil
                } else {
                    self.employeeUI = employee
                    self.managerUI = nil
                }

            } catch {
                self.errorMessage = error.localizedDescription
            }
        }

        await loadTask?.value
    }
}
