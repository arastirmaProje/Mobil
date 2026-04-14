//
//  CreateTaskView.swift
//  personelim
//

import SwiftUI

@available(iOS 17.0, *)
struct CreateTaskView: View {

    @StateObject private var vm: CreateTaskViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    init() {
        let network = NetworkManager()
        let repo = TaskRepositoryImpl(network: network)
        let useCase = CreateTaskUseCase(repository: repo)

        _vm = StateObject(
            wrappedValue: CreateTaskViewModel(createTaskUseCase: useCase)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    titleSection
                    calendarSection
                    taskTitleSection
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

            // ✅ FIX: navigationDestination yerine sheet
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
}

// MARK: - UI Sections
private extension CreateTaskView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Görev oluşturucu")
                .font(.title.bold())

            Text("Bir tarih aralığı seçin")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MultiDatePicker(
                "Tarih aralığı",
                selection: $vm.selectedDates
            )
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "tr_TR"))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .padding(.horizontal)
    }

    var taskTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Görev başlığı")
                .font(.headline)

            TextField("Başlık girin", text: $vm.title)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    var taskDetailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Görev detayı")
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

            Text("Görevi ata")
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

        return names.isEmpty ? "Çalışan seçiniz" : names.joined(separator: ", ")
    }
}
