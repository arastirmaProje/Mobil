//
//  Invitation DTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

struct SendInvitationRequestDTO: Encodable {
    let businessId: String
    let email: String
    let message: String?
}

struct SendInvitationResponseDTO: Decodable {
    let success: Bool
    let message: String
}
