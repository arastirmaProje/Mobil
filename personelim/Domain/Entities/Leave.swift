//
//  Leave.swift
//  personelim
//
//  Created by Tuğberk Acabey on 30.12.2025.
//

import Foundation

enum LeaveStatus: String, Codable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}

struct LeaveEntity: Identifiable {
    let id: String
    let title: String
    let description: String?
    let startDate: Date
    let endDate: Date
    let status: LeaveStatus
    let dayCount: Int
}
