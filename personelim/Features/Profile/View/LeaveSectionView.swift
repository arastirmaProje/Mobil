import SwiftUI

struct LeaveSectionView: View {

    let leaves: [LeaveEntity]
    let onCreateLeave: () -> Void
    let onShowAll: () -> Void

    private var sortedLeaves: [LeaveEntity] {
        leaves.sorted { $0.startDate > $1.startDate }
    }

    private var latestLeaves: [LeaveEntity] {
        Array(sortedLeaves.prefix(3))
    }

    private var approvedLeaveDays: Int {
        leaves
            .filter { $0.status == .approved }
            .reduce(0) { $0 + $1.dayCount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if latestLeaves.isEmpty {
                emptyCard
            } else {
                VStack(spacing: 10) {
                    ForEach(latestLeaves, id: \.id) { leave in
                        leaveRequestCard(leave)
                    }

                    if leaves.count > 3 {
                        showAllButton
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ConstantStrings.leavesTitle)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Text(ConstantStrings.leavesSubtitle)

                    Text("•")

                    Label(
                        String(format: ConstantStrings.usedLeaveDayCountFormat, approvedLeaveDays),
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onCreateLeave) {
                Label(ConstantStrings.useLeaveButton, systemImage: "calendar.badge.plus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Leave Card

    private func leaveRequestCard(_ leave: LeaveEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                statusIconBox(leave.status)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(leave.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        statusBadge(leave.status)
                    }

                    Text(dateLine(for: leave))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            if leave.status == .rejected {
                infoMiniRow(
                    icon: "xmark.circle.fill",
                    title: ConstantStrings.rejectionReasonTitle,
                    value: trimmedOrNil(leave.rejectionReason) ?? ConstantStrings.dashPlaceholder
                )
            }
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

    // MARK: - Show All

    private var showAllButton: some View {
        Button(action: onShowAll) {
            HStack(spacing: 8) {
                Text(ConstantStrings.showAllButton)
                    .font(.system(size: 14, weight: .bold))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.blue)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.blue.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Status UI

    private func statusIconBox(_ status: LeaveStatus) -> some View {
        ZStack {
            Circle()
                .fill(statusColor(status).opacity(0.12))

            Image(systemName: statusIcon(status))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(statusColor(status))
        }
        .frame(width: 44, height: 44)
    }

    private func statusBadge(_ status: LeaveStatus) -> some View {
        Text(statusTitle(status))
            .font(.caption2.weight(.bold))
            .foregroundStyle(statusColor(status))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(statusColor(status).opacity(0.12))
            )
    }

    private func infoMiniRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    // MARK: - Empty

    private var emptyCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(ConstantStrings.noLeaveRequestTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.noLeaveRequestDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func dateLine(for leave: LeaveEntity) -> String {
        let start = leave.startDate.trShortDate()
        let end = leave.endDate.trShortDate()
        let dayText = String(format: ConstantStrings.leaveDayCountFormat, leave.dayCount)

        if start == end {
            return "\(start) • \(dayText)"
        }

        return "\(start) - \(end) • \(dayText)"
    }

    private func statusTitle(_ status: LeaveStatus) -> String {
        switch status {
        case .pending:
            return ConstantStrings.pendingStatus
        case .approved:
            return ConstantStrings.approvedStatus
        case .rejected:
            return ConstantStrings.rejectedStatus
        }
    }

    private func statusColor(_ status: LeaveStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .approved:
            return .green
        case .rejected:
            return .red
        }
    }

    private func statusIcon(_ status: LeaveStatus) -> String {
        switch status {
        case .pending:
            return "clock.fill"
        case .approved:
            return "checkmark.circle.fill"
        case .rejected:
            return "xmark.circle.fill"
        }
    }

    private func trimmedOrNil(_ value: String?) -> String? {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
