//
//  TaskCardView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

import SwiftUI

struct TaskCardView: View {

    let task: TaskEntity
    let currentUserId: String?

    private var isCompleted: Bool {
        task.statusEnum == .done
    }

    private var isClosed: Bool {
        task.statusEnum == .closed
    }

    private var isExpired: Bool {
        !isCompleted && !isClosed && task.endDate < Date()
    }

    private var statusText: String {
        if isCompleted { return ConstantStrings.completedText }
        if isClosed { return ConstantStrings.closedText }
        if isExpired { return ConstantStrings.expiredText }
        return ConstantStrings.pendingText
    }

    private var statusColor: Color {
        if isCompleted { return .green }
        if isClosed { return .gray }
        if isExpired { return .red }
        return .orange
    }

    private var createdByText: String {
        if let name = task.assignedByName {
            return "\(name) \(ConstantStrings.sentBySuffix)"
        }
        return ""
    }
    var body: some View {
        HStack(spacing: 12) {

            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 6) {
                    Text(task.title)
                        .font(.body.bold())

                    Circle()
                        .fill(task.activityType.color)
                        .frame(width: 7, height: 7)

                    Text(task.activityType.rawValue)
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }

                Text(createdByText)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(
                    task.startDate.formatted(date: .abbreviated, time: .omitted)
                    + " - " +
                    task.endDate.formatted(date: .abbreviated, time: .omitted)
                )
                .font(.caption2)
                .foregroundColor(.secondary)

                Text(statusText)
                    .font(.caption.bold())
                    .foregroundColor(statusColor)
            }

            Spacer()

            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.primary)
                )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}
