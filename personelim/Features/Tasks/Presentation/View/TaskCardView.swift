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

    private var statusIcon: String {
        if isCompleted { return "checkmark.circle.fill" }
        if isClosed { return "lock.circle.fill" }
        if isExpired { return "exclamationmark.circle.fill" }
        return "clock.circle.fill"
    }

    private var createdByText: String {
        if let name = task.assignedByName {
            return "\(name) \(ConstantStrings.sentBySuffix)"
        }
        return ""
    }

    private var dateRangeText: String {
        task.startDate.formatted(date: .abbreviated, time: .omitted)
        + " - " +
        task.endDate.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 13) {

         
            VStack(alignment: .leading, spacing: 8) {

                HStack(alignment: .top, spacing: 8) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Spacer(minLength: 4)

                    statusBadge
                }

                activityBadge

                if !createdByText.isEmpty {
                    infoLine(
                        icon: "person.fill",
                        text: createdByText
                    )
                }

                infoLine(
                    icon: "calendar",
                    text: dateRangeText
                )
            }

            trailingIcon
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.025), radius: 8, y: 4)
    }

    // MARK: - Leading Icon

   

    private var activityIcon: String {
        switch task.activityType.rawValue.lowercased() {
        case let value where value.contains("görev") || value.contains("task"):
            return "checklist"

        case let value where value.contains("toplantı") || value.contains("meeting"):
            return "person.2.fill"

        case let value where value.contains("izin") || value.contains("leave"):
            return "calendar.badge.clock"

        case let value where value.contains("rapor") || value.contains("report"):
            return "doc.text.fill"

        default:
            return "tray.full.fill"
        }
    }

    // MARK: - Badges

    private var statusBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: statusIcon)
                .font(.system(size: 11, weight: .semibold))

            Text(statusText)
                .font(.caption2.weight(.bold))
                .lineLimit(1)
        }
        .foregroundStyle(statusColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.12))
        )
    }

    private var activityBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(task.activityType.color)
                .frame(width: 6, height: 6)

            Text(task.activityType.rawValue)
                .font(.caption.weight(.semibold))
                .foregroundStyle(task.activityType.color)
                .lineLimit(1)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(task.activityType.color.opacity(0.10))
        )
    }

    // MARK: - Info Line

    private func infoLine(icon: String, text: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 14)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    // MARK: - Trailing Icon

    private var trailingIcon: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary.opacity(0.8))
    }
}
