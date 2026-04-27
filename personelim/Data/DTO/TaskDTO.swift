//
//  TaskDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 20.12.2025.
//

import Foundation

struct TaskDTO: Decodable {
    let id: String
    let title: String?
    let description: String?
    let assignedToName: String?
    let assignedByName: String?
    let startDate: String
    let endDate: String
    let status: String
    let difficulty: String?
    let thoughts: String?
    let isOverdue: Bool
    let createdAt: String
}

extension TaskDTO {
    func toEntity() -> TaskEntity {
        return TaskEntity(
            id: id,
            title: title ?? "",
            description: description,
            assignedToName: assignedToName,
            assignedByName: assignedByName,
            startDate: ISODate.date(from: startDate) ?? .now,
            endDate: ISODate.date(from: endDate) ?? .now,
            status: status,
            activityType: .task,
            isOverdue: isOverdue
        )
    }
}
