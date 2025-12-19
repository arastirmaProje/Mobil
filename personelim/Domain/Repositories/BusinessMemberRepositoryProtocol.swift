//
//  BusinessMemberRepositoryProtocol.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

protocol BusinessMemberRepositoryProtocol {
    func getMembers(businessId: String) async throws -> [BusinessMemberDTO]
    func getMember(memberId: String) async throws -> BusinessMemberDTO
    func updateMember(memberId: String, request: UpdateBusinessMemberRequestDTO) async throws
    func uploadDocument(
        memberId: String,
        documentType: String,
        fileData: Data,
        fileName: String
    ) async throws -> BusinessMemberDocumentDTO
}
