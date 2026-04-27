//
//  TaskDetailView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

import SwiftUI

struct TaskDetailView: View {

    // MARK: - Properties
    let task: TaskEntity
    let currentUserId: String?
    private let updateStatusUseCase: UpdateActivityStatusUseCase

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // MARK: - UI State
    @State private var showStatusPicker = false
    @State private var selectedStatus: TaskStatus?
    @State private var navigateToFeedback = false
    @State private var errorMessage: String?

    enum TaskStatus: String {
        case done = "DONE"
        case closed = "CLOSED"

        var displayName: String {
            switch self {
            case .done: return ConstantStrings.completedText
            case .closed: return ConstantStrings.closedText
            }
        }
    }

    init(
        task: TaskEntity,
        currentUserId: String?,
        updateStatusUseCase: UpdateActivityStatusUseCase = UpdateActivityStatusUseCase(
            taskRepository: TaskRepositoryImpl(network: NetworkManager()),
            scheduleRepository: ScheduleRepositoryImpl(network: NetworkManager())
        )
    ) {
        self.task = task
        self.currentUserId = currentUserId
        self.updateStatusUseCase = updateStatusUseCase
    }

    // MARK: - Derived States
    private var isCompleted: Bool {
        selectedStatus == .done || task.statusEnum == .done
    }

    private var isClosed: Bool {
        selectedStatus == .closed || task.statusEnum == .closed
    }

    private var isExpired: Bool {
        !isCompleted && !isClosed && task.endDate < Date()
    }

    private var statusText: String {
        if isCompleted { return TaskStatus.done.displayName }
        if isClosed { return TaskStatus.closed.displayName }
        if isExpired { return ConstantStrings.expiredText }
        return ConstantStrings.pendingText
    }

    private var statusColor: Color {
        if isCompleted { return .green }
        if isClosed { return .gray }
        if isExpired { return .red }
        return .orange
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    dateSection
                    descriptionSection
                    statusSection
                    footerSection

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 32)
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToFeedback) {
                TaskFeedbackView(
                    task: task,
                    finalStatus: selectedStatus?.rawValue ?? TaskStatus.done.rawValue
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if selectedStatus == .done || selectedStatus == .closed {
                            navigateToFeedback = true
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(
                                selectedStatus == nil ? .secondary : .primary
                            )
                            .font(.headline)
                    }
                    .disabled(selectedStatus == nil)
                }
            }
            .alert(
                ConstantStrings.errorTitle,
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { _ in errorMessage = nil }
                )
            ) {
                Button(ConstantStrings.okButton, role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
}

// MARK: - Sections
private extension TaskDetailView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(task.title)
                .font(.title2.bold())

            HStack(spacing: 8) {
                Circle()
                    .fill(task.activityType.color)
                    .frame(width: 10, height: 10)

                Text(task.activityType.rawValue)
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)

                Text(statusText)
                    .font(.caption.bold())
                    .foregroundColor(statusColor)
            }

            if let assignedBy = task.assignedByName {
                Text("\(assignedBy) \(ConstantStrings.assignedBySuffix)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ConstantStrings.dateRangeLabel)
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.startDateLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(task.startDate.formatted(date: .long, time: .omitted))
                        .font(.body.bold())
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.endDateLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(task.endDate.formatted(date: .long, time: .omitted))
                        .font(.body.bold())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ConstantStrings.activityDetailLabel)
                .font(.headline)

            Text(task.description ?? ConstantStrings.noDetailText)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    var statusSection: some View {
        Group {
            if task.activityType == .task {
                VStack(alignment: .leading, spacing: 8) {
                    Text(ConstantStrings.statusSelectLabel)
                        .font(.headline)

                    Button {
                        withAnimation {
                            showStatusPicker.toggle()
                        }
                    } label: {
                HStack {
                            Text(selectedStatus?.displayName ?? ConstantStrings.pickerSelect)
                                .foregroundColor(
                                    selectedStatus == nil ? .secondary : .primary
                                )

                            Spacer()

                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    if showStatusPicker {
                        VStack(spacing: 0) {
                            Button {
                                selectedStatus = .done
                                showStatusPicker = false
                            } label: {
                                HStack {
                                    Text(TaskStatus.done.displayName)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding()
                            }

                            Divider()

                            Button {
                                selectedStatus = .closed
                                showStatusPicker = false
                            } label: {
                                HStack {
                                    Text(TaskStatus.closed.displayName)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    var footerSection: some View {
        VStack(spacing: 12) {
            if isCompleted {
                Label(ConstantStrings.activityDoneFooter, systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if isClosed {
                Label(ConstantStrings.activityClosedFooter, systemImage: "xmark.circle.fill")
                    .foregroundColor(.gray)
            } else if isExpired {
                Label(ConstantStrings.activityExpiredFooter, systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
    }
}
