import SwiftUI
import PhotosUI

@MainActor
final class EditPersonalProfileViewModel: ObservableObject {

    @Published var email = ""
    @Published var firstName = ""
    @Published var lastName = ""

    @Published var photoItem: PhotosPickerItem?
    @Published var photoData: Data?
    @Published var remoteImageUrl: String?

    @Published var tcIdentityNumber: String = ""
    private var initialTCIdentityNumber: String = ""

    private var initialEmail: String = ""
    private var initialFirstName: String = ""
    private var initialLastName: String = ""
    private var initialRemoteImageUrl: String?

    @Published var cvURL: URL?
    @Published var documentURL: URL?

    @Published var existingCVs: [BusinessMemberDocumentDTO] = []
    @Published var existingDocuments: [BusinessMemberDocumentDTO] = []

    @Published var isLoading = false
    @Published var isDeletingDoc = false
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

    // MARK: - Load

    func load() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let p = try await authRepo.getProfile()

            email = p.email
            firstName = p.firstName ?? ""
            lastName = p.lastName ?? ""
            remoteImageUrl = p.imageUrl

            initialEmail = email
            initialFirstName = firstName
            initialLastName = lastName
            initialRemoteImageUrl = remoteImageUrl

            let businesses = try await businessRepo.getBusinesses()

            guard let business = businesses.first else {
                clearDocumentsAndTC()
                return
            }

            let members = try await memberRepo.getMembers(
                businessId: business.id
            )

            guard let me = members.first(
                where: { $0.userId.lowercased() == p.id.lowercased() }
            ) else {
                clearDocumentsAndTC()
                return
            }

            let detail = try await memberRepo.getMember(
                memberId: me.id
            )

            tcIdentityNumber = detail.tcIdentityNumber ?? ""
            initialTCIdentityNumber = tcIdentityNumber

            let docs = detail.documents ?? []
            existingCVs = docs.filter { $0.documentType.uppercased() == "CV" }
            existingDocuments = docs.filter { $0.documentType.uppercased() != "CV" }

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.profileNotRetrivied
            )
        }
    }

    // MARK: - Photo

    func onPickPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                photoData = data
            }
        } catch {
            errorMessage = ConstantStrings.profileImageLoadFailed
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

    // MARK: - Save

    func save() async throws {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        var didChangeAnything = false

        do {
            if shouldUpdateProfile() {
                _ = try await authRepo.updateProfile(
                    email: email.trimmed,
                    firstName: firstName.trimmed,
                    lastName: lastName.trimmed,
                    imageData: photoData
                )

                didChangeAnything = true
            }

            let tcUpdated = try await updateTCIdentityIfNeeded()

            if tcUpdated {
                didChangeAnything = true
            }

            let uploaded = try await uploadSelectedPDFsIfNeeded()

            if uploaded {
                didChangeAnything = true
            }

            if didChangeAnything {
                photoData = nil
                photoItem = nil
                cvURL = nil
                documentURL = nil

                await load()
            }

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.profileUpdateFail
            )
            throw error
        }
    }

    // MARK: - Delete account

    func deleteMyAccount() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await authRepo.deleteAccount()
            TokenStore.shared.clear()
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.deleteAccountFail
            )
        }
    }

    // MARK: - Delete document

    func deleteDocument(_ doc: BusinessMemberDocumentDTO) async {
        isDeletingDoc = true
        errorMessage = nil

        defer {
            isDeletingDoc = false
        }

        do {
            try await memberRepo.deleteMemberDocument(
                documentId: doc.id
            )

            if doc.documentType.uppercased() == "CV" {
                existingCVs.removeAll { $0.id == doc.id }
            } else {
                existingDocuments.removeAll { $0.id == doc.id }
            }

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.memberDocumentDeleteFail
            )
        }
    }

    // MARK: - Helpers

    private func shouldUpdateProfile() -> Bool {
        let e = email.trimmed
        let f = firstName.trimmed
        let l = lastName.trimmed

        if e != initialEmail { return true }
        if f != initialFirstName { return true }
        if l != initialLastName { return true }
        if photoData != nil { return true }

        return false
    }

    private func updateTCIdentityIfNeeded() async throws -> Bool {
        let tc = tcIdentityNumber.trimmed
        let initial = initialTCIdentityNumber.trimmed

        guard tc != initial else { return false }
        guard !tc.isEmpty else { return false }

        let auth = try await authRepo.getProfile()
        let myUserId = auth.id

        let businesses = try await businessRepo.getBusinesses()
        guard let business = businesses.first else { return false }

        let members = try await memberRepo.getMembers(
            businessId: business.id
        )

        guard let me = members.first(
            where: { $0.userId.lowercased() == myUserId.lowercased() }
        ) else {
            return false
        }

        let req = UpdateBusinessMemberRequestDTO(
            role: me.role.apiIntValue,
            positionId: me.positionId,
            salary: me.salary,
            tcIdentityNumber: tc
        )

        try await memberRepo.updateMember(
            memberId: me.id,
            request: req
        )

        initialTCIdentityNumber = tc
        return true
    }

    private func uploadSelectedPDFsIfNeeded() async throws -> Bool {
        if cvURL == nil && documentURL == nil {
            return false
        }

        let auth = try await authRepo.getProfile()
        let myUserId = auth.id

        let businesses = try await businessRepo.getBusinesses()
        guard let business = businesses.first else { return false }

        let members = try await memberRepo.getMembers(
            businessId: business.id
        )

        guard let me = members.first(
            where: { $0.userId.lowercased() == myUserId.lowercased() }
        ) else {
            return false
        }

        var didUpload = false

        if let url = cvURL {
            let data = try readFileData(url: url)

            _ = try await memberRepo.uploadDocument(
                memberId: me.id,
                documentType: "CV",
                fileData: data,
                fileName: url.lastPathComponent.isEmpty
                    ? "cv.pdf"
                    : url.lastPathComponent
            )

            didUpload = true
        }

        if let url = documentURL {
            let data = try readFileData(url: url)

            _ = try await memberRepo.uploadDocument(
                memberId: me.id,
                documentType: "DOCUMENT",
                fileData: data,
                fileName: url.lastPathComponent.isEmpty
                    ? "document.pdf"
                    : url.lastPathComponent
            )

            didUpload = true
        }

        return didUpload
    }

    private func readFileData(url: URL) throws -> Data {
        let needsSecurity = url.startAccessingSecurityScopedResource()

        defer {
            if needsSecurity {
                url.stopAccessingSecurityScopedResource()
            }
        }

        return try Data(contentsOf: url)
    }

    private func clearDocumentsAndTC() {
        existingCVs = []
        existingDocuments = []
        tcIdentityNumber = ""
        initialTCIdentityNumber = ""
    }

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

// MARK: - String Helper

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
