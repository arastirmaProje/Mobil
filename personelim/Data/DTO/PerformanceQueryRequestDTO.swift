//
//  PerformanceQueryRequestDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

struct PerformanceQueryRequestDTO: Codable {
    let businessId: String
    let employeeUserId: String
    let startDate: String
    let endDate: String
}
