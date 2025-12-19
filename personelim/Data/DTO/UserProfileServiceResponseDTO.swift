//
//  UserProfileServiceResponseDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

struct UserProfileServiceResponseDTO: Codable {
    let success: Bool
    let message: String?
    let data: UserProfileDTO?
    let errors: [String]?
}
