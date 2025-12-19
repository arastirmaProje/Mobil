//
//  Untitled.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

struct CreateBusinessServiceResponseDTO: Codable {
    let success: Bool
    let message: String?
    let data: CreateBusinessResponseDTO?
    let errors: [String]?
}
