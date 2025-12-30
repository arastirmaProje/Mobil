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
        ScrollView {
            VStack(spacing: 24) {

                topBar
                titleSection
                calendarSection
                leaveTitleSection
                leaveDetailSection

                Spacer(minLength: 32)
            }
            .padding(.bottom, 40)
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

private extension CreateLeaveView {

    var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }

            Spacer()

            Button {
                Task {
                    let success = await vm.createLeave()
                    if success {
                        dismiss()
                    }
                }
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(
                        vm.isFormValid ? .primary : .secondary
                    )
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .disabled(!vm.isFormValid || vm.isLoading)
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

private extension CreateLeaveView {

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("İzin oluştur")
                .font(.title.bold())

            Text("Bir tarih aralığı seçin")
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
                "Tarih aralığı",
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
            Text("İzin başlığı")
                .font(.headline)

            TextField("Başlık girin", text: $vm.title)
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
            Text("İzin açıklaması")
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
