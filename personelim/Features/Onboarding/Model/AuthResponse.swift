//
//  AuthResponse.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import Foundation

struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let data: AuthUser?
    let errors: [String]?
}

struct AuthUser: Codable {
    let userId: String
    let email: String
    let fullName: String
    let token: String
    let expiresAt: String
}

