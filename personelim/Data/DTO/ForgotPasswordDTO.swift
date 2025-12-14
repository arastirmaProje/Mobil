//
//  ForgotPasswordDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

struct ForgotPasswordRequestDTO: Encodable {
    let email: String
}

struct ForgotPasswordResponseDTO: Decodable {
    let email: String?
    let expiresAt: String?
    let expiresInMinutes: Int?
}

struct ForgotPasswordServiceResponseDTO: Decodable {
    let success: Bool
    let message: String?
    let data: ForgotPasswordResponseDTO?
    let errors: [String]?
}
