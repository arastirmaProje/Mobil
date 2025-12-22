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

    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Init
    init(task: TaskEntity) {
        let repo = TaskRepositoryImpl(network: NetworkManager())
        _vm = StateObject(
            wrappedValue: TaskFeedbackViewModel(
                taskId: task.id,
                repo: repo
            )
        )
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                topBar
                headerSection
                feedbackSection
                difficultySection

                Spacer(minLength: 40)
            }
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
        .alert(
            "Hata",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { _ in vm.errorMessage = nil }
            )
        ) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}

private extension TaskFeedbackView {

    var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }

            Spacer()

            Button {
                Task {
                    let success = await vm.submit()
                    if success {
                        presentationMode.wrappedValue.dismiss()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(
                        vm.isValid ? .primary : .secondary
                    )
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .disabled(!vm.isValid || vm.isSaving)
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

private extension TaskFeedbackView {

    var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Düşünceler")
                .font(.headline)

            TextEditor(text: $vm.feedbackText)
                .frame(height: 140)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

private extension TaskFeedbackView {

    var difficultySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Seviye seçiniz")
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
                Text("Çok kolay")
                Spacer()
                Text("Çok zor")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

private extension TaskFeedbackView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Görev Geri Bildirimi")
                .font(.title.bold())

            Text("Bu görevle ilgili deneyimini paylaş")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
