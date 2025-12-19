//  Data Transfer Object
//
//  AuthResponseDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

struct AuthResponseDTO: Codable {
    let userId: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let fullName: String?
    let token: String?
    let expiresAt: String?
    let role: UserRole?
}

struct AuthResponseServiceDTO: Codable {
    let success: Bool
    let message: String?
    let data: AuthResponseDTO?
    let errors: [String]?
}
