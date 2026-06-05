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
            case .done:
                return ConstantStrings.completedText
            case .closed:
                return ConstantStrings.closedText
            }
        }

        var icon: String {
            switch self {
            case .done:
                return "checkmark.circle.fill"
            case .closed:
                return "xmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .done:
                return .green
            case .closed:
                return .gray
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

    private var statusIcon: String {
        if isCompleted { return "checkmark.circle.fill" }
        if isClosed { return "xmark.circle.fill" }
        if isExpired { return "exclamationmark.triangle.fill" }
        return "clock.circle.fill"
    }

    private var canContinue: Bool {
        selectedStatus == .done || selectedStatus == .closed
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        heroSection

                        dateSection

                        descriptionSection

                        statusSection

                        footerSection

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomContinueButton
            }
            .navigationTitle("Aktivite Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToFeedback) {
                TaskFeedbackView(
                    task: task,
                    finalStatus: selectedStatus?.rawValue ?? TaskStatus.done.rawValue
                )
                .environmentObject(appState)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
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

    var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(task.activityType.color.opacity(0.12))

                    Image(systemName: activityIcon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(task.activityType.color)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(3)

                    HStack(spacing: 8) {
                        activityBadge
                        statusBadge
                    }
                }

                Spacer()
            }

            if let assignedBy = task.assignedByName {
                infoLine(
                    icon: "person.fill",
                    text: "\(assignedBy) \(ConstantStrings.assignedBySuffix)"
                )
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    var dateSection: some View {
        sectionCard(title: ConstantStrings.dateRangeLabel) {
            HStack(spacing: 0) {
                dateBox(
                    title: ConstantStrings.startDateLabel,
                    date: task.startDate,
                    icon: "calendar.badge.play"
                )

                Divider()
                    .padding(.vertical, 10)

                dateBox(
                    title: ConstantStrings.endDateLabel,
                    date: task.endDate,
                    icon: "calendar.badge.clock"
                )
            }
        }
    }

    var descriptionSection: some View {
        sectionCard(title: ConstantStrings.activityDetailLabel) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)

                Text(task.description ?? ConstantStrings.noDetailText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(
                        task.description == nil ? .secondary : .primary
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .formRowBackground()
        }
    }

    @ViewBuilder
    var statusSection: some View {
        if task.activityType == .task {
            sectionCard(title: ConstantStrings.statusSelectLabel) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        showStatusPicker.toggle()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selectedStatus?.icon ?? "circle.dashed")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(selectedStatus?.color ?? .secondary)
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Seçili Durum")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            Text(selectedStatus?.displayName ?? ConstantStrings.pickerSelect)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(selectedStatus == nil ? .secondary : .primary)
                        }

                        Spacer()

                        Image(systemName: showStatusPicker ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .formRowBackground()
                }
                .buttonStyle(.plain)

                if showStatusPicker {
                    VStack(spacing: 0) {
                        statusOption(.done)

                        Divider()
                            .padding(.leading, 58)

                        statusOption(.closed)
                    }
                    .background(Color(.systemBackground))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    @ViewBuilder
    var footerSection: some View {
        if isCompleted {
            footerMessage(
                text: ConstantStrings.activityDoneFooter,
                icon: "checkmark.circle.fill",
                color: .green
            )
        } else if isClosed {
            footerMessage(
                text: ConstantStrings.activityClosedFooter,
                icon: "xmark.circle.fill",
                color: .gray
            )
        } else if isExpired {
            footerMessage(
                text: ConstantStrings.activityExpiredFooter,
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
        }
    }

    var bottomContinueButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                guard canContinue else { return }

                appState.signalActivitiesChanged()
                navigateToFeedback = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")

                    Text("Devam Et")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canContinue ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canContinue)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }
}

// MARK: - UI Pieces

private extension TaskDetailView {

    var activityIcon: String {
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

    var activityBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(task.activityType.color)
                .frame(width: 6, height: 6)

            Text(task.activityType.rawValue)
                .font(.caption.weight(.semibold))
                .foregroundStyle(task.activityType.color)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(task.activityType.color.opacity(0.10))
        )
    }

    var statusBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: statusIcon)
                .font(.system(size: 11, weight: .semibold))

            Text(statusText)
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(statusColor)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.12))
        )
    }

    func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 2)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
    }

    func dateBox(
        title: String,
        date: Date,
        icon: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(date.formatted(date: .long, time: .omitted))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
    }

    func statusOption(_ status: TaskStatus) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selectedStatus = status
                showStatusPicker = false
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: status.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(status.color)
                    .frame(width: 32, height: 32)

                Text(status.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                if selectedStatus == status {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .formRowBackground()
        }
        .buttonStyle(.plain)
    }

    func footerMessage(
        text: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)

            Spacer()
        }
        .padding(14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func infoLine(
        icon: String,
        text: String
    ) -> some View {
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
}

// MARK: - Row Background

private extension View {
    func formRowBackground() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.055))
                    .frame(height: 0.7)
                    .padding(.leading, 58)
            }
    }
}
