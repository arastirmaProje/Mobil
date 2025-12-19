//
//  BusinessMemberServiceResponseDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

struct BusinessMemberServiceResponseDTO: Codable {
    let success: Bool
    let message: String?
    let data: [BusinessMemberDTO]?
    let errors: [String]?
}
