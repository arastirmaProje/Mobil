//
//  ScheduleDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 26.04.2026.
//

import Foundation

struct ScheduleDTO: Decodable {
    let id: String
    let title: String?
    let description: String?
    let date: String
    let type: Int

    func toEntity() -> TaskEntity {
        let dateValue = ISODate.date(from: date) ?? .now
        let activityType: ActivityType = (type == 1) ? .event : .meeting

        return TaskEntity(
            id: id,
            title: title ?? "",
            description: description,
            assignedToName: nil,
            assignedByName: nil,
            startDate: dateValue,
            endDate: dateValue,
            status: "Beklemede",
            activityType: activityType,
            isOverdue: dateValue < Date()
        )
    }
}
