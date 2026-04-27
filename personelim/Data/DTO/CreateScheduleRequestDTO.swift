//
//  CreateScheduleRequestDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 26.04.2026.
//

import Foundation

struct CreateScheduleRequestDTO: Encodable {
    let businessId: String
    let title: String?
    let description: String?
    let date: String
    let type: Int

    init(
        businessId: String,
        title: String,
        description: String,
        date: Date,
        activityType: ActivityType
    ) {
        self.businessId = businessId
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = t.isEmpty ? nil : t

        let d = description.trimmingCharacters(in: .whitespacesAndNewlines)
        self.description = d.isEmpty ? nil : d

        self.date = ISODate.string(from: date)

        switch activityType {
        case .meeting:
            self.type = 0
        case .event:
            self.type = 1
        case .task:
            assertionFailure("CreateScheduleRequestDTO should not be used for ActivityType.task")
            self.type = 0
        }
    }
}
