//
//  UpdateLeaveStatusRequestDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 30.12.2025.
//

import Foundation

struct UpdateLeaveStatusRequestDTO: Encodable {
    let status: Int
    let rejectionReason: String?
}
