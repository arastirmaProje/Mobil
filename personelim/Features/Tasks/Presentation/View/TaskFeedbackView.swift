//
//  TaskFeedbackView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

import SwiftUI

struct TaskFeedbackView: View {

    // MARK: - State
    @StateObject private var vm: TaskFeedbackViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init
    init(task: TaskEntity, finalStatus: String) {
        let network = NetworkManager()
        let updateStatusUseCase = UpdateActivityStatusUseCase(
            taskRepository: TaskRepositoryImpl(network: network),
            scheduleRepository: ScheduleRepositoryImpl(network: network)
        )
        _vm = StateObject(
            wrappedValue: TaskFeedbackViewModel(
                taskId: task.id,
                activityType: task.activityType,
                finalStatus: finalStatus,
                updateStatusUseCase: updateStatusUseCase
            )
        )
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    feedbackSection
                    difficultySection

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 32)
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
                            let success = await vm.submit()
                            if success {
                                appState.signalActivitiesChanged()
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(vm.isValid ? .primary : .secondary)
                            .font(.headline)
                    }
                    .disabled(!vm.isValid || vm.isSaving)
                }
            }
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

// MARK: - Sections
private extension TaskFeedbackView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ConstantStrings.feedbackTitle)
                .font(.title.bold())

            Text(ConstantStrings.feedbackSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ConstantStrings.feedbackThoughtsLabel)
                .font(.headline)

            TextEditor(text: $vm.feedbackText)
                .frame(height: 140)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    var difficultySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ConstantStrings.feedbackLevelLabel)
                .font(.headline)

            Slider(
                value: Binding(
                    get: { Double(vm.difficulty) },
                    set: { vm.difficulty = Int($0) }
                ),
                in: 1...5,
                step: 1
            )

            HStack {
                Text(ConstantStrings.feedbackVeryEasy)
                Spacer()
                Text(ConstantStrings.feedbackVeryHard)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}
