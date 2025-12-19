//
//  BusinessMemberRepositoryImpl.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

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
            throw RepositoryError.api(message: response.message ?? "Üye listesi alınamadı")
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
            throw RepositoryError.api(message: res.message ?? "Üye detayı alınamadı")
        }

        return data
    }

    func updateMember(memberId: String, request: UpdateBusinessMemberRequestDTO) async throws {

        let res: ServiceResponse<Bool> = try await network.request(
            endpoint: .updateBusinessMember(memberId: memberId),
            method: .put,
            body: request
        )

        guard res.success else {
            throw RepositoryError.api(message: res.message ?? "Üye güncellenemedi")
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

        let res: ServiceResponse<BusinessMemberDocumentDTO> = try await network.uploadMultipart(
            endpoint: .uploadMemberDocuments(memberId: memberId),
            method: .post,
            fields: fields,
            files: [file]
        )

        guard res.success, let data = res.data else {
            throw RepositoryError.api(message: res.message ?? "Belge yüklenemedi")
        }

        return data
    }
}
