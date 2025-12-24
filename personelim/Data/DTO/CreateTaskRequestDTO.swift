//
//  CreateTaskRequestDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 22.12.2025.
//

import Foundation

struct CreateTaskRequestDTO: Encodable {
    let businessId: String
    let assignedToUserId: String
    let title: String
    let description: String
    let startDate: String
    let endDate: String

    init(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        assignedToUserId: String
    ) {
        self.businessId = businessId
        self.assignedToUserId = assignedToUserId
        self.title = title
        self.description = description
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        self.startDate = iso.string(from: startDate)
        self.endDate = iso.string(from: endDate)
    }
}
