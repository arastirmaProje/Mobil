//
//  SlackIntegration.swift
//  personelim
//
//  Created by Tuğberk Acabey on 06.05.2026.
//

import Foundation

enum SlackActivityType: String, CaseIterable, Identifiable, Hashable {
    case meeting
    case task
    case event

    var id: String { rawValue }

    var title: String {
        switch self {
        case .meeting:
            return ConstantStrings.slackActivityMeeting
        case .task:
            return ConstantStrings.slackActivityTask
        case .event:
            return ConstantStrings.slackActivityEvent
        }
    }

    var backendValue: String {
        switch self {
        case .meeting:
            return "meeting_created"
        case .task:
            return "task_created"
        case .event:
            return "event_created"
        }
    }

    static func fromBackendValue(_ value: String?) -> SlackActivityType? {
        let normalized = (value ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if normalized.contains("meeting") || normalized.contains("toplanti") {
            return .meeting
        }

        if normalized.contains("task") || normalized.contains("gorev") {
            return .task
        }

        if normalized.contains("event") || normalized.contains("etkinlik") {
            return .event
        }

        return SlackActivityType.allCases.first { $0.backendValue == normalized }
    }
}

struct SlackWebhookRecord: Hashable {
    let id: String
    let activityType: SlackActivityType
}

struct SlackIntegration: Identifiable, Hashable {
    let id: String
    let label: String
    let webhookUrl: String
    let eventTypes: [SlackActivityType]
    let records: [SlackWebhookRecord]
}
