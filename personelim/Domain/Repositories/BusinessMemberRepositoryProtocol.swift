//
//  BusinessMemberRepositoryProtocol.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

protocol BusinessMemberRepositoryProtocol {
    func getMembers(businessId: String) async throws -> [BusinessMemberDTO]
}
