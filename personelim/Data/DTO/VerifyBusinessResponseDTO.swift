//
//  VerifyBusinessResponseDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 15.12.2025.
//

import Foundation

struct VerifyBusinessResponseDTO: Decodable {
    let success: Bool
    let message: String
    let data: Bool
}
