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
        let endOfSelectedDay = Self.endOfDay(dateValue)
        let isPast = endOfSelectedDay < Date()

        return TaskEntity(
            id: id,
            title: title ?? "",
            description: description,
            assignedToName: nil,
            assignedByName: nil,
            startDate: dateValue,
            endDate: endOfSelectedDay,
            status: isPast ? "Süresi Geçti" : "Beklemede",
            activityType: activityType,
            isOverdue: isPast
        )
    }

    private static func endOfDay(_ date: Date) -> Date {
        Calendar.current.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: date
        ) ?? date
    }
}
