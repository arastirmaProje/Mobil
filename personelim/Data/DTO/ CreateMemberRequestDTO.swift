//
//   CreateMemberRequestDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import Foundation

struct CreateMemberRequestDTO: Encodable {
    let businessId: String
    let email: String
    let firstName: String
    let lastName: String
    let positionId: Int
    let departmentId: String
    let salary: Double
    let tcIdentityNumber: String? 
}
