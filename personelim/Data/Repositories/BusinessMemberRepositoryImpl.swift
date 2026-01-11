import Foundation

final class BusinessMemberRepositoryImpl: BusinessMemberRepositoryProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    func getMembers(businessId: String) async throws -> [BusinessMemberDTO] {
        let response: BusinessMemberServiceResponseDTO = try await network.request(
            endpoint: .businessMembers(businessId: businessId),
            method: .get,
            body: nil
        )

        guard let data = response.data else {
            throw RepositoryError.api(
                message: response.message ?? ConstantStrings.membersFetchFail
            )
        }

        return data
    }

    func getMember(memberId: String) async throws -> BusinessMemberDTO {
        let res: ServiceResponse<BusinessMemberDTO> = try await network.request(
            endpoint: .getBusinessMember(memberId: memberId),
            method: .get,
            body: nil
        )

        guard res.success, let data = res.data else {
            throw RepositoryError.api(
                message: res.message ?? ConstantStrings.memberDetailFail
            )
        }

        return data
    }

    func updateMember(
        memberId: String,
        request: UpdateBusinessMemberRequestDTO
    ) async throws {

        let res: ServiceResponse<Bool> = try await network.request(
            endpoint: .updateBusinessMember(memberId: memberId),
            method: .put,
            body: request
        )

        guard res.success else {
            throw RepositoryError.api(
                message: res.message ?? ConstantStrings.memberUpdateFail
            )
        }
    }

    func uploadDocument(
        memberId: String,
        documentType: String,
        fileData: Data,
        fileName: String
    ) async throws -> BusinessMemberDocumentDTO {

        let fields: [String: String] = [
            "documentType": documentType
        ]

        let file = MultipartFile(
            fieldName: "file",
            fileName: fileName,
            mimeType: "application/pdf",
            data: fileData
        )

        let res: ServiceResponse<BusinessMemberDocumentDTO> =
            try await network.uploadMultipart(
                endpoint: .uploadMemberDocuments(memberId: memberId),
                method: .post,
                fields: fields,
                files: [file]
            )

        guard res.success, let data = res.data else {
            throw RepositoryError.api(
                message: res.message ?? ConstantStrings.memberDocumentUploadFail
            )
        }

        return data
    }

    func deleteMemberDocument(documentId: String) async throws {
        let res: ServiceResponse<Bool> = try await network.request(
            endpoint: .deleteMemberDocument(documentId: documentId),
            method: .delete,
            body: nil
        )

        guard res.success else {
            throw RepositoryError.api(
                message: res.message ?? ConstantStrings.memberDocumentDeleteFail
            )
        }
    }

    func deleteMember(memberId: String) async throws -> EmptyResponse {
        let res: EmptyResponse = try await network.request(
            endpoint: .deleteBusinessMember(memberId: memberId),
            method: .delete,
            body: nil
        )
        return res
    }
}


    // üye belgesi güncellem eklenmesi lazım
  //  func updateMemberDocument<T: Encodable>(
  //      documentId: String,
    //      body: T
    //  ) async throws -> BusinessMemberDocumentDTO {

    //    let res: ServiceResponse<BusinessMemberDocumentDTO> = try await network.request(
    //       endpoint: .updateMemberDocument(documentId: documentId),
    //       method: .put,
    //       body: body
    //    )

    //    guard res.success, let data = res.data else {
    //        throw RepositoryError.api(message: res.message ?? "Belge güncellenemedi")
    //   }

    //   return data
    // }

