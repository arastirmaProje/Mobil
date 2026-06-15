//
//  LeaveStatusUpdateRequestDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 15.06.2026.
//

import Foundation

struct LeaveStatusUpdateRequestDTO: Encodable {
    let status: Int
    let rejectionReason: String?
}
