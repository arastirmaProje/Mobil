//
//  BusinessMemberDTO.swift.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

struct BusinessMemberDTO: Codable {
    let id: String
    let userId: String
    let fullName: String
    let email: String

    let phoneNumber: String?
    let role: UserRole

    let position: String?
    let salary: Double?
    let tcIdentityNumber: String?

    let joinedAt: String?
    let isActive: Bool?
    let documents: [BusinessMemberDocumentDTO]?
}
