//
//  ShiftDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

struct ShiftDTO: Codable, Identifiable {
    let id: String
    let businessId: String?
    let startTime: String?
    let endTime: String?
}
