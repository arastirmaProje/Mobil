import SwiftUI
import PhotosUI

@MainActor
final class EditPersonalProfileViewModel: ObservableObject {

    @Published var email = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var photoItem: PhotosPickerItem?
    @Published var photoData: Data?
    @Published var tcIdentityNumber: String = ""
    @Published var cvURL: URL?
    @Published var documentURL: URL?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authRepo: AuthRepositoryProtocol
    private let businessRepo: BusinessRepositoryProtocol
    private let memberRepo: BusinessMemberRepositoryProtocol

    init(
        authRepo: AuthRepositoryProtocol,
        businessRepo: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager()),
        memberRepo: BusinessMemberRepositoryProtocol = BusinessMemberRepositoryImpl(network: NetworkManager())
    ) {
        self.authRepo = authRepo
        self.businessRepo = businessRepo
        self.memberRepo = memberRepo
    }

    func load() async {
        do {
            isLoading = true
            let p = try await authRepo.getProfile()
            email = p.email
            firstName = p.firstName ?? ""
            lastName = p.lastName ?? ""
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func onPickPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                photoData = data
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setTC(_ value: String) {
        tcIdentityNumber = value
    }

    func setCV(url: URL) {
        cvURL = url
    }

    func setDocument(url: URL) {
        documentURL = url
    }

    func save() async throws {
        isLoading = true
        defer { isLoading = false }

        _ = try await authRepo.updateProfile(
            email: email,
            firstName: firstName,
            lastName: lastName,
            imageData: photoData
        )

    
        try await updateTCIdentityIfNeeded()
        try await uploadSelectedPDFsIfNeeded()
    }

    // MARK: - TC Update
    private func updateTCIdentityIfNeeded() async throws {
        let tc = tcIdentityNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tc.isEmpty else { return }

   
        let auth = try await authRepo.getProfile()
        let myUserId = auth.id

   
        let businesses = try await businessRepo.getBusinesses()
        guard let business = businesses.first else { return }

 
        let members = try await memberRepo.getMembers(businessId: business.id)
        guard let me = members.first(where: { $0.userId.lowercased() == myUserId.lowercased() }) else { return }

        let memberId = me.id

        let req = UpdateBusinessMemberRequestDTO(
            role: nil,
            position: nil,
            salary: nil,
            tcIdentityNumber: tc
        )

        try await memberRepo.updateMember(memberId: memberId, request: req)

     
        let detail = try await memberRepo.getMember(memberId: memberId)
        print("✅ MEMBER DETAIL (after TC update) tcIdentityNumber:", detail.tcIdentityNumber ?? "nil")
    }

    // MARK: - Upload PDFs
    private func uploadSelectedPDFsIfNeeded() async throws {
        if cvURL == nil && documentURL == nil { return }

    
        let auth = try await authRepo.getProfile()
        let myUserId = auth.id

       
        let businesses = try await businessRepo.getBusinesses()
        guard let business = businesses.first else { return }


        let members = try await memberRepo.getMembers(businessId: business.id)
        guard let me = members.first(where: { $0.userId.lowercased() == myUserId.lowercased() }) else { return }

        let memberId = me.id

        if let url = cvURL {
            let data = try readFileData(url: url)
            _ = try await memberRepo.uploadDocument(
                memberId: memberId,
                documentType: "CV",
                fileData: data,
                fileName: url.lastPathComponent.isEmpty ? "cv.pdf" : url.lastPathComponent
            )
        }

        if let url = documentURL {
            let data = try readFileData(url: url)
            _ = try await memberRepo.uploadDocument(
                memberId: memberId,
                documentType: "DOCUMENT",
                fileData: data,
                fileName: url.lastPathComponent.isEmpty ? "document.pdf" : url.lastPathComponent
            )
        }

        let detail = try await memberRepo.getMember(memberId: memberId)
        print("✅ MEMBER DETAIL DOCUMENTS:", detail.documents ?? [])
    }

    private func readFileData(url: URL) throws -> Data {
        let needsSecurity = url.startAccessingSecurityScopedResource()
        defer { if needsSecurity { url.stopAccessingSecurityScopedResource() } }
        return try Data(contentsOf: url)
    }
}
