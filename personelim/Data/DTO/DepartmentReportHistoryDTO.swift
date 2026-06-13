//
//  DepartmentReportHistoryDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 13.06.2026.
//

import Foundation

struct DepartmentReportHistoryDTO: Decodable, Identifiable {
    let id: String
    let businessId: String
    let departmentId: String
    let departmanAdi: String
    let periodStart: String
    let periodEnd: String
    let departmanSkoru: Double
    let toplamCalisan: Int
    let createdAt: String
}
