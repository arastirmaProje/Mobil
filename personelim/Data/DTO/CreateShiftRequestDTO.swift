//
//  CreateShiftRequestDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

struct CreateShiftRequestDTO: Codable {
    let businessId: String
    let startTime: String
    let endTime: String
}
