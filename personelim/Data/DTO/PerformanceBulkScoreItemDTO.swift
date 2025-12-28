//
//  PerformanceBulkScoreItemDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 28.12.2025.
//

import Foundation

struct PerformanceBulkScoreItemDTO: Decodable, Identifiable {
    var id: String { (employeeUserId ?? calisanId ?? UUID().uuidString) }

    let employeeUserId: String?
    let calisanId: String?

    let performanceScore: Double?
    let performansSkoru: Double?

    var userId: String? { employeeUserId ?? calisanId }
    var score: Double? { performanceScore ?? performansSkoru }
}
