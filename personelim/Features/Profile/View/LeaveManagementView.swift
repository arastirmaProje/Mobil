//
//  LeaveManagementView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 15.06.2026.
//

import SwiftUI

struct LeaveManagementView: View {

    let businessId: String

    @StateObject private var vm = LeaveApprovalViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFilter: LeaveFilter = .pending
    @State private var selectedLeave: LeaveDTO?
    @State private var showRejectSheet = false
    @State private var rejectionReason = ""

    private var filteredLeaves: [LeaveDTO] {
        switch selectedFilter {
        case .all:
            return vm.leaves
        case .pending:
            return vm.leaves.filter { $0.status == .pending }
        case .approved:
            return vm.leaves.filter { $0.status == .approved }
        case .rejected:
            return vm.leaves.filter { $0.status == .rejected }
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

                    if vm.isLoading {
                        loadingView
                    } else if let error = vm.errorMessage {
                        errorCard(error)
                    } else if filteredLeaves.isEmpty {
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
            .refreshable {
                await vm.loadLeaves(businessId: businessId)
            }
        }
        .navigationTitle(ConstantStrings.leaveRequestsTitle)
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
        .task {
            await vm.loadLeaves(businessId: businessId)
        }
        .sheet(isPresented: $showRejectSheet) {
            rejectSheet
                .presentationDetents([.medium])
        }
    }

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.leaveRequestsTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.leaveRequestsSubtitle)
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
                ForEach(LeaveFilter.allCases, id: \.self) { filter in
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
                                    .fill(selectedFilter == filter ? filter.color : filter.color.opacity(0.10))
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

    private func leaveCard(_ leave: LeaveDTO) -> some View {
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
                    Text(leave.memberNameText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(leave.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                statusBadge(leave.status)
            }

            Divider()

            VStack(spacing: 10) {
                infoRow(
                    icon: "calendar",
                    title: ConstantStrings.dateRangeLabel,
                    value: "\(leave.startDate.trShortDate()) - \(leave.endDate.trShortDate())"
                )

                infoRow(
                    icon: "clock",
                    title: ConstantStrings.selectedDayTitle,
                    value: String(format: ConstantStrings.leaveDayCountFormat, leave.dayCount)
                )

                if let description = leave.description,
                   !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    infoRow(
                        icon: "text.alignleft",
                        title: ConstantStrings.leaveDescriptionLabel,
                        value: description
                    )
                }
            }

            if leave.status == .pending {
                HStack(spacing: 10) {
                    Button {
                        Task {
                            await vm.approveLeave(
                                leave,
                                businessId: businessId
                            )
                        }
                    } label: {
                        Label(ConstantStrings.approveLeaveButton, systemImage: "checkmark.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        selectedLeave = leave
                        rejectionReason = ""
                        showRejectSheet = true
                    } label: {
                        Label(ConstantStrings.rejectLeaveButton, systemImage: "xmark.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
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
                    .multilineTextAlignment(.leading)
            }

            Spacer()
        }
    }

    private func statusBadge(_ status: LeaveStatus) -> some View {
        Text(statusTitle(status))
            .font(.caption2.weight(.bold))
            .foregroundStyle(statusColor(status))
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(statusColor(status).opacity(0.12))
            )
    }

    private var loadingView: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.loadingText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(16)
        .background(cardBackground(cornerRadius: 18))
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

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(14)
        .background(Color.red.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.20), lineWidth: 1)
        )
    }

    private var rejectSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text(ConstantStrings.rejectionReasonTitle)
                    .font(.headline)

                TextEditor(text: $rejectionReason)
                    .font(.system(size: 15))
                    .frame(height: 140)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )

                Spacer()
            }
            .padding(18)
            .navigationTitle(ConstantStrings.rejectLeaveButton)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ConstantStrings.cancelButton) {
                        showRejectSheet = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(ConstantStrings.rejectLeaveButton) {
                        guard let selectedLeave else { return }

                        Task {
                            await vm.rejectLeave(
                                selectedLeave,
                                reason: rejectionReason,
                                businessId: businessId
                            )

                            showRejectSheet = false
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(rejectionReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
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
}

private enum LeaveFilter: CaseIterable {
    case pending
    case approved
    case rejected
    case all

    var title: String {
        switch self {
        case .pending:
            return ConstantStrings.pendingStatus
        case .approved:
            return ConstantStrings.approvedStatus
        case .rejected:
            return ConstantStrings.rejectedStatus
        case .all:
            return ConstantStrings.allFilterTitle
        }
    }

    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .approved:
            return .green
        case .rejected:
            return .red
        case .all:
            return .blue
        }
    }
}

private extension LeaveDTO {

    var memberNameText: String {
        let name = memberName?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return name?.isEmpty == false
            ? name!
            : ConstantStrings.employeeTitle
    }
}
