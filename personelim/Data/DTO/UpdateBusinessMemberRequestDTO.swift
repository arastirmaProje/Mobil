//
//  UpdateBusinessMemberRequestDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 18.12.2025.
//

import Foundation

struct UpdateBusinessMemberRequestDTO: Encodable {
    let role: Int?
    let positionId: Int?
    let salary: Double?
    let tcIdentityNumber: String?
}
