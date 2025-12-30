//
//  PerformanceBulkScoreResponseDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 30.12.2025.
//

import Foundation

struct PerformanceBulkScoreResponseDTO: Decodable {
    let totalEmployees: Int?
    let scores: [PerformanceBulkScoreItemDTO]

    enum CodingKeys: String, CodingKey {
        case totalEmployees = "toplam_calisan"
        case scores = "skorlar"
    }
}
