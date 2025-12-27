//
//  PerformanceReportDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

struct PerformanceReportDTO: Codable, Identifiable {
    let id: String

    let businessId: String?
    let employeeUserId: String?

    let createdByName: String?
    let startDate: String?
    let endDate: String?

    let score: Int?
    let summaryText: String?

}
