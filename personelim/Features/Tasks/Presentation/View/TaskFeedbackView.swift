import SwiftUI

struct TaskFeedbackView: View {

    @StateObject private var vm: TaskFeedbackViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

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

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection

                        feedbackSection

                        difficultySection

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomSubmitButton
            }
            .navigationTitle(ConstantStrings.feedbackNavTitle)
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
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.10))

                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 5) {
                    Text(ConstantStrings.feedbackTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(ConstantStrings.feedbackSubtitle)
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

    var feedbackSection: some View {
        sectionCard(title: ConstantStrings.feedbackThoughtsLabel) {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $vm.feedbackText)
                    .font(.system(size: 15, weight: .medium))
                    .frame(height: 150)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text(String(format: ConstantStrings.characterCountFormat, vm.feedbackText.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(14)
            .background(Color(.systemBackground))
        }
    }

    var difficultySection: some View {
        sectionCard(title: ConstantStrings.feedbackLevelLabel) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    difficultyIcon

                    VStack(alignment: .leading, spacing: 4) {
                        Text(difficultyTitle)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(difficultyColor)

                        Text(String(format: ConstantStrings.levelFormat, vm.difficulty))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                Slider(
                    value: Binding(
                        get: { Double(vm.difficulty) },
                        set: { vm.difficulty = Int($0) }
                    ),
                    in: 1...5,
                    step: 1
                )
                .tint(difficultyColor)

                HStack {
                    Text(ConstantStrings.feedbackVeryEasy)
                    Spacer()
                    Text(ConstantStrings.feedbackVeryHard)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                difficultyDots
            }
            .padding(14)
            .background(Color(.systemBackground))
        }
    }

    var bottomSubmitButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    let success = await vm.submit()

                    if success {
                        appState.signalActivitiesChanged()
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if vm.isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }

                    Text(vm.isSaving ? ConstantStrings.savingText : ConstantStrings.saveButtonShort)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(vm.isValid && !vm.isSaving ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!vm.isValid || vm.isSaving)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }
}

// MARK: - UI Pieces

private extension TaskFeedbackView {

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

    var difficultyIcon: some View {
        ZStack {
            Circle()
                .fill(difficultyColor.opacity(0.12))

            Image(systemName: difficultySystemIcon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(difficultyColor)
        }
        .frame(width: 46, height: 46)
    }

    var difficultyDots: some View {
        HStack(spacing: 7) {
            ForEach(1...5, id: \.self) { value in
                Circle()
                    .fill(value <= vm.difficulty ? difficultyColor : Color.black.opacity(0.08))
                    .frame(width: 9, height: 9)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    var difficultyTitle: String {
        switch vm.difficulty {
        case 1:
            return ConstantStrings.feedbackVeryEasy
        case 2:
            return ConstantStrings.difficultyEasy
        case 3:
            return ConstantStrings.difficultyMedium
        case 4:
            return ConstantStrings.difficultyHard
        default:
            return ConstantStrings.feedbackVeryHard
        }
    }

    var difficultySystemIcon: String {
        switch vm.difficulty {
        case 1:
            return "leaf.fill"
        case 2:
            return "hand.thumbsup.fill"
        case 3:
            return "minus.circle.fill"
        case 4:
            return "flame.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }

    var difficultyColor: Color {
        switch vm.difficulty {
        case 1:
            return .green
        case 2:
            return .mint
        case 3:
            return .orange
        case 4:
            return .red.opacity(0.85)
        default:
            return .red
        }
    }
}
