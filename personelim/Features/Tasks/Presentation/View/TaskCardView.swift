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
        task.status.lowercased() == "tamamlandı"
    }

    private var isExpired: Bool {
        !isCompleted && task.endDate < Date()
    }

    private var statusText: String {
        if isCompleted { return "Tamamlandı" }
        if isExpired { return "Süresi geçti" }
        return "Beklemede"
    }

    private var statusColor: Color {
        if isCompleted { return .green }
        if isExpired { return .red }
        return .orange
    }

    private var createdByText: String {
        if let name = task.assignedByName {
            return "\(name) tarafından gönderildi"
        }
        return ""
    }
    var body: some View {
        HStack(spacing: 12) {

            VStack(alignment: .leading, spacing: 6) {

                Text(task.title)
                    .font(.body.bold())

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
