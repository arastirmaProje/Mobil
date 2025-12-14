//
//  VerifyResetCodeResponseDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 7.12.2025.
//

import Foundation

struct VerifyResetCodeRequestDTO: Encodable {
    let email: String
    let code: String
}

struct VerifyResetCodeResponseDTO: Decodable {
    let success: Bool
    let message: String?
    let data: Bool?
    let errors: [String]?
}
