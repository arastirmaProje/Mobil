//
//  MyLeavesView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 15.06.2026.
//

import SwiftUI

struct MyLeavesView: View {

    let leaves: [LeaveEntity]

    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: MyLeaveFilter = .all

    private var sortedLeaves: [LeaveEntity] {
        leaves.sorted { $0.startDate > $1.startDate }
    }

    private var filteredLeaves: [LeaveEntity] {
        switch selectedFilter {
        case .all:
            return sortedLeaves
        case .pending:
            return sortedLeaves.filter { $0.status == .pending }
        case .approved:
            return sortedLeaves.filter { $0.status == .approved }
        case .rejected:
            return sortedLeaves.filter { $0.status == .rejected }
        }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerSection
                    filterSection

                    if filteredLeaves.isEmpty {
                        emptyState
                    } else {
                        leavesList
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle(ConstantStrings.myLeaveRequestsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "calendar")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.myLeaveRequestsTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.myLeaveRequestsSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(cardBackground(cornerRadius: 24))
    }

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MyLeaveFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.title)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(selectedFilter == filter ? .white : filter.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        selectedFilter == filter
                                        ? filter.color
                                        : filter.color.opacity(0.10)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var leavesList: some View {
        VStack(spacing: 12) {
            ForEach(filteredLeaves, id: \.id) { leave in
                leaveCard(leave)
            }
        }
    }

    private func leaveCard(_ leave: LeaveEntity) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(statusColor(leave.status).opacity(0.12))

                    Image(systemName: statusIcon(leave.status))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(statusColor(leave.status))
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(leave.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        statusBadge(leave.status)
                    }

                    Text(dateLine(for: leave))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

           

            if leave.status == .rejected {
                infoRow(
                    icon: "xmark.circle.fill",
                    title: ConstantStrings.rejectionReasonTitle,
                    value: trimmedOrNil(leave.rejectionReason) ?? ConstantStrings.dashPlaceholder
                )
            }
        }
        .padding(16)
        .background(cardBackground(cornerRadius: 22))
    }

    private func infoRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.blue)

            Text(ConstantStrings.noLeaveRequestTitle)
                .font(.headline)

            Text(ConstantStrings.noLeaveRequestDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 20)
        .background(cardBackground(cornerRadius: 22))
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

    private func dateLine(for leave: LeaveEntity) -> String {
        let start = leave.startDate.trShortDate()
        let end = leave.endDate.trShortDate()
        let dayText = String(format: ConstantStrings.leaveDayCountFormat, leave.dayCount)

        if start == end {
            return "\(start) • \(dayText)"
        }

        return "\(start) - \(end) • \(dayText)"
    }

    private func cardBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.045), radius: 12, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
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

private enum MyLeaveFilter: CaseIterable {
    case all
    case pending
    case approved
    case rejected

    var title: String {
        switch self {
        case .all:
            return ConstantStrings.allFilterTitle
        case .pending:
            return ConstantStrings.pendingStatus
        case .approved:
            return ConstantStrings.approvedStatus
        case .rejected:
            return ConstantStrings.rejectedStatus
        }
    }

    var color: Color {
        switch self {
        case .all:
            return .blue
        case .pending:
            return .orange
        case .approved:
            return .green
        case .rejected:
            return .red
        }
    }
}
