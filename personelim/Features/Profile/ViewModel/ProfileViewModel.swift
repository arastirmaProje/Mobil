import SwiftUI
import PDFKit

// MARK: - Sheet item (PDF Preview)
struct DocumentToPreview: Identifiable {
    let id: String
    let title: String
    let documentId: String
}

// MARK: - Office UI
struct OfficeUI: Identifiable {
    let id: String
    let name: String
    let address: String
}

// MARK: - Employee/Manager UI
struct EmployeeProfileUI {
    let fullName: String
    let position: String?
    let salaryText: String?
    let tcIdentityNumber: String?
    let email: String
    let imageUrl: String?
    let cvFiles: [BusinessMemberDocumentDTO]
    let documentFiles: [BusinessMemberDocumentDTO]
    let remainingLeaveDaysText: String
}

struct ManagerProfileUI {
    let companyName: String
    let companyDescription: String?
    let companyEmail: String
    let offices: [OfficeUI]
    let employee: EmployeeProfileUI
}

// MARK: - Profile ViewModel
@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var employeeUI: EmployeeProfileUI?
    @Published var managerUI: ManagerProfileUI?

    private let authRepo: AuthRepositoryProtocol
    private let memberRepo: BusinessMemberRepositoryProtocol
    private let businessRepo: BusinessRepositoryProtocol

    init(
        authRepo: AuthRepositoryProtocol = AuthRepositoryImpl(network: NetworkManager()),
        memberRepo: BusinessMemberRepositoryProtocol = BusinessMemberRepositoryImpl(network: NetworkManager()),
        businessRepo: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager())
    ) {
        self.authRepo = authRepo
        self.memberRepo = memberRepo
        self.businessRepo = businessRepo
    }

    func load(appState: AppState) async {
        isLoading = true
        errorMessage = nil
        employeeUI = nil
        managerUI = nil
        defer { isLoading = false }

        do {
            let auth = try await authRepo.getProfile()
            appState.userId = auth.id

            let businesses = try await businessRepo.getBusinesses()

            guard let business = businesses.first else {
                employeeUI = EmployeeProfileUI(
                    fullName: auth.fullName
                    ?? "\(auth.firstName ?? "") \(auth.lastName ?? "")"
                        .trimmingCharacters(in: .whitespacesAndNewlines),
                    position: nil,
                    salaryText: nil,
                    tcIdentityNumber: nil,
                    email: auth.email,
                    imageUrl: auth.imageUrl,
                    cvFiles: [],
                    documentFiles: [],
                    remainingLeaveDaysText: "4"
                )
                return
            }

            let businessId = business.id

            let members = try await memberRepo.getMembers(businessId: businessId)
            let me = members.first { $0.userId.lowercased() == auth.id.lowercased() }

            appState.role = me?.role ?? .default

            let salaryText: String? = {
                guard let s = me?.salary else { return nil }
                return "\(Int(s))TL"
            }()

            var cvFiles: [BusinessMemberDocumentDTO] = []
            var documentFiles: [BusinessMemberDocumentDTO] = []

            if let me {
                let detail = try await memberRepo.getMember(memberId: me.id)
                let docs = detail.documents ?? []
                cvFiles = docs.filter { $0.documentType.uppercased() == "CV" }
                documentFiles = docs.filter { $0.documentType.uppercased() != "CV" }
            }

            let employee = EmployeeProfileUI(
                fullName: me?.fullName
                ?? (auth.fullName
                    ?? "\(auth.firstName ?? "") \(auth.lastName ?? "")"
                        .trimmingCharacters(in: .whitespacesAndNewlines)),
                position: me?.position,
                salaryText: salaryText,
                tcIdentityNumber: me?.tcIdentityNumber,
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
                        let a = (o.address ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                        return OfficeUI(
                            id: o.id ?? "office-\(idx)",
                            name: n.isEmpty ? "Ofis \(idx + 1)" : n,
                            address: a.isEmpty ? "-" : a
                        )
                    }
                }

                let n = (business.locationName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let a = (business.address ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

                return [
                    OfficeUI(
                        id: "office-1",
                        name: n.isEmpty ? "Ofis 1" : n,
                        address: a.isEmpty ? "-" : a
                    )
                ]
            }()

            if appState.role.canSeePersonnelTab {
                managerUI = ManagerProfileUI(
                    companyName: business.name,
                    companyDescription: business.description,
                    companyEmail: auth.email,
                    offices: officesUI,
                    employee: employee
                )
            } else {
                employeeUI = employee
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
