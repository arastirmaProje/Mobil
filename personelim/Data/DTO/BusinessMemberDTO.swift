//
//  BusinessMemberDTO.swift.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

struct BusinessMemberDTO: Codable, Identifiable {
    let id: String
    let userId: String
    let fullName: String
    let email: String
    
    let departmentId: String?
    
    let positionId: Int?
    
    
    let phoneNumber: String?
    let role: UserRole

    let positionName: String?
    let salary: Double?
    let tcIdentityNumber: String?
    let position: String?

    let joinedAt: String?
    let isActive: Bool?
    let documents: [BusinessMemberDocumentDTO]?
    
    var firstName: String {
        fullName.components(separatedBy: " ").first ?? fullName
    }
    
    var lastName: String {
        let components = fullName.components(separatedBy: " ")
        return components.count > 1 ? components.last! : ""
    }
}
