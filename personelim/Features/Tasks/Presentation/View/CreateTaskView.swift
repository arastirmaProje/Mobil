//
//  CreateTaskView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

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
            ScrollView {
                VStack(spacing: 24) {

                    titleSection
                    calendarSection
                    taskTitleSection
                    activityTypeSection
                    taskDetailSection
                    assignUserSection

                    Spacer(minLength: 32)
                }
                .padding(.bottom, 40)
            }
            .navigationBarBackButtonHidden(true)
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
                        Task {
                            guard let bid = appState.businessId else { return }

                            let success = await vm.createTask(businessId: bid)
                            if success {
                                appState.signalActivitiesChanged()
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundStyle(vm.isFormValid ? .primary : .secondary)
                    }
                    .disabled(!vm.isFormValid || vm.isLoading)
                }
            }
            .task {
                let memberRepo = BusinessMemberRepositoryImpl(
                    network: NetworkManager()
                )
                await appState.loadBusinessMembersIfNeeded(repository: memberRepo)
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
            }

            .alert(
                ConstantStrings.errorTitle,
                isPresented: Binding(
                    get: { vm.errorMessage != nil },
                    set: { _ in vm.errorMessage = nil }
                )
            ) {
                Button(ConstantStrings.okButton, role: .cancel) {}
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }
}

// MARK: - UI Sections
private extension CreateTaskView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ConstantStrings.activityCreatorTitle)
                .font(.title.bold())

            Text(ConstantStrings.activityCreatorSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    var calendarSection: some View {
        VStack(spacing: 14) {
            RangeCalendarCard(
                startDate: $vm.startDate,
                endDate: $vm.endDate
            )

            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text(ConstantStrings.startTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(vm.startDate?.trShortDate() ?? "-")
                        .font(.body.bold())
                }

                VStack(alignment: .leading) {
                    Text(ConstantStrings.endTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(vm.endDate?.trShortDate() ?? "-")
                        .font(.body.bold())
                }

                Spacer()
            }
            .padding(.horizontal)
        }
    }

    var taskTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ConstantStrings.activityTitleLabel)
                .font(.headline)

            TextField(ConstantStrings.activityTitlePlaceholder, text: $vm.title)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    var activityTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ConstantStrings.activityTypeLabel)
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(ActivityType.allCases) { type in
                    Button {
                        vm.activityType = type
                    } label: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(type.color)
                                .frame(width: 8, height: 8)

                            Text(type.rawValue)
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(vm.activityType == type ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(vm.activityType == type ? Color.primary : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
    }

    var taskDetailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ConstantStrings.activityDetailLabel)
                .font(.headline)

            TextEditor(text: $vm.detail)
                .frame(height: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    var assignUserSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(ConstantStrings.activityAssignLabel)
                .font(.headline)

            Button {
                vm.showAssigneePicker = true
            } label: {
                HStack {

                    Text(selectedNames)
                        .foregroundColor(
                            vm.selectedAssignees.isEmpty
                            ? .secondary
                            : .primary
                        )

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    var selectedNames: String {
        let names = appState.businessMembers
            .filter { vm.selectedAssignees.contains($0.userId) }
            .map { $0.fullName }

        return names.isEmpty
            ? ConstantStrings.selectEmployeePlaceholder
            : names.joined(separator: ", ")
    }
}
