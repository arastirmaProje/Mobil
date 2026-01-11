//
//  Task.swift
//  personelim
//
//  Created by Tuğberk Acabey on 20.12.2025.
//

import Foundation

struct TaskEntity: Identifiable {
    let id: String
    let title: String
    let description: String?
    let assignedToName: String?
    let assignedByName: String?
    let startDate: Date
    let endDate: Date
    let status: String
    let isOverdue: Bool
}

extension TaskEntity {
    var statusEnum: TaskStatus? {
        TaskStatus(rawValue: status)
    }
}

extension TaskEntity {
    static func test(id: String,status: String) -> TaskEntity {
        TaskEntity(id: id, title: "Test",
                   description: nil,
                   assignedToName: nil,
                   assignedByName: nil,
                   startDate: Date(),
                   endDate: Date(),
                   status: status,
                   isOverdue: false)
    }
}


