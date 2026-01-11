//
//  CreateLeaveView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 30.12.2025.
//

import SwiftUI

@available(iOS 17.0, *)
struct CreateLeaveView: View {

    // MARK: - State
    @StateObject private var vm: CreateLeaveViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init
    init(businessId: String) {
        let repo = LeaveRepositoryImpl(network: NetworkManager())
        _vm = StateObject(
            wrappedValue: CreateLeaveViewModel(
                businessId: businessId,
                repo: repo
            )
        )
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    titleSection
                    calendarSection
                    leaveTitleSection
                    leaveDetailSection

                    Spacer(minLength: 32)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("İzin oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            let success = await vm.createLeave()
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                    }
                    .disabled(!vm.isFormValid || vm.isLoading)
                }
            }
            .alert(ConstantStrings.leaveErrorTitle, isPresented: Binding(
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

private extension CreateLeaveView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ConstantStrings.createLeaveTitle)
                .font(.title.bold())

            Text(ConstantStrings.createLeaveSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

private extension CreateLeaveView {

    var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MultiDatePicker(
                ConstantStrings.dateRangeLabel,
                selection: $vm.selectedDates
            )
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "tr_TR"))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(
            color: .black.opacity(0.05),
            radius: 10,
            y: 4
        )
        .padding(.horizontal)
    }
}

private extension CreateLeaveView {

    var leaveTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ConstantStrings.leaveTitleLabel)
                .font(.headline)

            TextField(ConstantStrings.leaveTitlePlaceholder, text: $vm.title)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

private extension CreateLeaveView {

    var leaveDetailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ConstantStrings.leaveDescriptionLabel)
                .font(.headline)

            TextEditor(text: $vm.description)
                .frame(height: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}
