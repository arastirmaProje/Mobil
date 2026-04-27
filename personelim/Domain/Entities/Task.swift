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
    let activityType: ActivityType
    let isOverdue: Bool
}

extension TaskEntity {
    var statusEnum: TaskStatus? {
        TaskStatus(status)
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
                   activityType: .task,
                   isOverdue: false)
    }
}

enum ActivityType: String, CaseIterable, Identifiable {
    case meeting = "Toplantı"
    case task = "Görev"
    case event = "Etkinlik"

    var id: String { rawValue }

    var apiValue: String {
        switch self {
        case .meeting:
            return "Meeting"
        case .task:
            return "Task"
        case .event:
            return "Event"
        }
    }

    init(rawValue: String?, defaultType: ActivityType = .task) {
        guard let rawValue else {
            self = defaultType
            return
        }

        switch rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "toplantı", "toplanti", "meeting":
            self = .meeting
        case "etkinlik", "event":
            self = .event
        default:
            self = defaultType
        }
    }
}
