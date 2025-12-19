//
//  UserProfileDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

struct UserProfileDTO: Codable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let fullName: String?
    let phoneNumber: String?
    let createdAt: String?
    let lastLoginAt: String?
    let businessCount: Int?
    let ownedBusinessCount: Int?
    let imageUrl: String?
}


