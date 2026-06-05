
import SwiftUI

@available(iOS 17.0, *)
struct CreateTaskView: View {

    @StateObject private var vm: CreateTaskViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    init() {
        let network = NetworkManager()

        let taskRepository = TaskRepositoryImpl(network: network)
        let scheduleRepository = ScheduleRepositoryImpl(network: network)

        let useCase = CreateActivityUseCase(
            taskRepository: taskRepository,
            scheduleRepository: scheduleRepository
        )

        _vm = StateObject(
            wrappedValue: CreateTaskViewModel(createActivityUseCase: useCase)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        titleSection
                        calendarSection
                        taskTitleSection
                        activityTypeSection
                        taskDetailSection
                        assignUserSection

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomCreateButton
            }
            .navigationTitle("Aktivite Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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
            .task {
                let memberRepo = BusinessMemberRepositoryImpl(
                    network: NetworkManager()
                )

                await appState.loadBusinessMembersIfNeeded(
                    repository: memberRepo
                )
            }
            .sheet(isPresented: $vm.showAssigneePicker) {
                NavigationStack {
                    AssigneePickerView(
                        members: appState.businessMembers,
                        selectedAssignees: $vm.selectedAssignees,
                        onDone: {
                            vm.showAssigneePicker = false
                        }
                    )
                }
                .presentationDetents([.large])
            }
            .alert(
                ConstantStrings.errorTitle,
                isPresented: Binding(
                    get: { vm.errorMessage != nil },
                    set: { _ in vm.errorMessage = nil }
                )
            ) {
                Button(ConstantStrings.okButton, role: .cancel) { }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }
}

// MARK: - UI Sections

@available(iOS 17.0, *)
private extension CreateTaskView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.10))

                    Image(systemName: "plus.rectangle.on.rectangle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 5) {
                    Text(ConstantStrings.activityCreatorTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(ConstantStrings.activityCreatorSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()
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

    var calendarSection: some View {
        sectionCard(title: vm.activityType == .task ? "Tarih Aralığı" : "Tarih") {
            VStack(spacing: 14) {

                RangeCalendarCard(
                    startDate: singleAwareStartDate,
                    endDate: singleAwareEndDate
                )

                if vm.activityType == .task {
                    HStack(spacing: 0) {
                        dateSummaryBox(
                            title: ConstantStrings.startTitle,
                            value: vm.startDate?.trShortDate() ?? "-",
                            icon: "calendar.badge.play"
                        )

                        Divider()
                            .padding(.vertical, 10)

                        dateSummaryBox(
                            title: ConstantStrings.endTitle,
                            value: vm.endDate?.trShortDate() ?? "-",
                            icon: "calendar.badge.clock"
                        )
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                } else {
                    dateSummaryBox(
                        title: "Seçilen Tarih",
                        value: vm.startDate?.trShortDate() ?? "-",
                        icon: "calendar"
                    )
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                }
            }
            .padding(14)
            .background(Color(.systemBackground))
        }
    }

    var taskTitleSection: some View {
        sectionCard(title: ConstantStrings.activityTitleLabel) {
            formTextField(
                title: ConstantStrings.activityTitleLabel,
                placeholder: ConstantStrings.activityTitlePlaceholder,
                text: $vm.title,
                icon: "textformat"
            )
        }
    }

    var activityTypeSection: some View {
        sectionCard(title: ConstantStrings.activityTypeLabel) {
            VStack(spacing: 0) {
                ForEach(ActivityType.allCases) { type in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            vm.activityType = type

                            if type != .task {
                                let date = vm.startDate ?? Date()
                                vm.startDate = date
                                vm.endDate = date
                            }
                        }
                    } label: {
                        activityTypeRow(type)
                    }
                    .buttonStyle(.plain)

                    if type.id != ActivityType.allCases.last?.id {
                        Divider()
                            .padding(.leading, 58)
                    }
                }
            }
        }
    }

    var taskDetailSection: some View {
        sectionCard(title: ConstantStrings.activityDetailLabel) {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $vm.detail)
                    .font(.system(size: 15, weight: .medium))
                    .frame(height: 130)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text("\(vm.detail.count) karakter")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(14)
            .background(Color(.systemBackground))
        }
    }

    var assignUserSection: some View {
        sectionCard(title: ConstantStrings.activityAssignLabel) {
            Button {
                vm.showAssigneePicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Atanan kişiler")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text(selectedNames)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(
                                vm.selectedAssignees.isEmpty ? .secondary : .primary
                            )
                            .lineLimit(2)
                    }

                    Spacer()

                    selectedAssigneeBadge

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .formRowBackground()
            }
            .buttonStyle(.plain)
        }
    }

    var bottomCreateButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    guard let businessId = appState.businessId else { return }

                    if vm.activityType != .task {
                        let date = vm.startDate ?? Date()
                        vm.startDate = date
                        vm.endDate = date
                    }

                    let success = await vm.createTask(businessId: businessId)

                    if success {
                        appState.signalActivitiesChanged()
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }

                    Text(vm.isLoading ? "Oluşturuluyor..." : ConstantStrings.createTaskButton)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(vm.isFormValid && !vm.isLoading ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!vm.isFormValid || vm.isLoading)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }

    var selectedNames: String {
        let names = appState.businessMembers
            .filter { vm.selectedAssignees.contains($0.userId) }
            .map { $0.fullName }

        return names.isEmpty
            ? ConstantStrings.selectEmployeePlaceholder
            : names.joined(separator: ", ")
    }

    var selectedAssigneeBadge: some View {
        Group {
            if vm.selectedAssignees.isEmpty {
                EmptyView()
            } else {
                Text("\(vm.selectedAssignees.count)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
        }
    }

    var singleAwareStartDate: Binding<Date?> {
        Binding(
            get: {
                vm.startDate
            },
            set: { newDate in
                vm.startDate = newDate

                if vm.activityType != .task {
                    vm.endDate = newDate
                }
            }
        )
    }

    var singleAwareEndDate: Binding<Date?> {
        Binding(
            get: {
                vm.activityType == .task ? vm.endDate : vm.startDate
            },
            set: { newDate in
                if vm.activityType == .task {
                    vm.endDate = newDate
                } else {
                    vm.startDate = newDate
                    vm.endDate = newDate
                }
            }
        )
    }
}

// MARK: - UI Pieces

@available(iOS 17.0, *)
private extension CreateTaskView {

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

    func dateSummaryBox(
        title: String,
        value: String,
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

                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(value == "-" ? .secondary : .primary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
    }

    func formTextField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        icon: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField(placeholder, text: text)
                    .font(.system(size: 15, weight: .medium))
            }
        }
        .formRowBackground()
    }

    func activityTypeRow(_ type: ActivityType) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(type.color.opacity(0.12))

                Circle()
                    .fill(type.color)
                    .frame(width: 8, height: 8)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(type.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(activityTypeSubtitle(for: type))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if vm.activityType == type {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.blue)
            } else {
                Circle()
                    .stroke(Color.black.opacity(0.12), lineWidth: 1.3)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            vm.activityType == type
            ? Color.blue.opacity(0.035)
            : Color(.systemBackground)
        )
    }

    func activityTypeSubtitle(for type: ActivityType) -> String {
        if type == .task {
            return "Başlangıç ve bitiş tarihi seçilir"
        } else {
            return "Tek tarih seçilir"
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

