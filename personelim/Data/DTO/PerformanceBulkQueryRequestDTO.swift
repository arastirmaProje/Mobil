//
//  PerformanceBulkQueryRequestDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 28.12.2025.
//

import Foundation

struct PerformanceBulkQueryRequestDTO: Encodable {
    let businessId: String
    let startDate: String
    let endDate: String
}
