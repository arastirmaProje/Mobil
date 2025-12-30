//
//  CreateLeaveRequestDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 30.12.2025.
//

import Foundation

struct CreateLeaveRequestDTO: Encodable {
    let businessId: String
    let title: String
    let description: String
    let startDate: String
    let endDate: String

    init(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date
    ) {
        self.businessId = businessId
        self.title = title
        self.description = description

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
            .withInternetDateTime
        ]

        self.startDate = formatter.string(from: startDate)
        self.endDate = formatter.string(from: endDate)
    }
}
