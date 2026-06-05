import SwiftUI

@available(iOS 17.0, *)
struct CreateLeaveView: View {

    @StateObject private var vm: CreateLeaveViewModel
    @Environment(\.dismiss) private var dismiss

    init(businessId: String) {
        let repo = LeaveRepositoryImpl(network: NetworkManager())
        _vm = StateObject(
            wrappedValue: CreateLeaveViewModel(
                businessId: businessId,
                repo: repo
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
                        titleSection
                        calendarSection
                        leaveTitleSection
                        leaveDetailSection

                        if let error = vm.errorMessage {
                            errorCard(error)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomCreateButton
            }
            .navigationTitle("İzin oluştur")
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
            .alert(
                ConstantStrings.leaveErrorTitle,
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

// MARK: - Sections

@available(iOS 17.0, *)
private extension CreateLeaveView {

    var titleSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.createLeaveTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.createLeaveSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
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
        sectionCard(title: ConstantStrings.dateRangeLabel) {
            VStack(spacing: 14) {
                MultiDatePicker(
                    ConstantStrings.dateRangeLabel,
                    selection: $vm.selectedDates
                )
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "tr_TR"))
                .tint(.blue)
                .padding(10)
                .background(Color(.systemBackground))

                selectedDatesSummary
            }
            .padding(14)
            .background(Color(.systemBackground))
        }
    }

    var selectedDatesSummary: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text("Seçilen gün")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("\(vm.selectedDates.count) gün seçildi")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(vm.selectedDates.isEmpty ? .secondary : .primary)
            }

            Spacer()
        }
        .formRowBackground()
    }

    var leaveTitleSection: some View {
        sectionCard(title: ConstantStrings.leaveTitleLabel) {
            inputRow(
                title: ConstantStrings.leaveTitleLabel,
                text: $vm.title,
                icon: "textformat",
                placeholder: ConstantStrings.leaveTitlePlaceholder
            )
        }
    }

    var leaveDetailSection: some View {
        sectionCard(title: ConstantStrings.leaveDescriptionLabel) {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $vm.description)
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

                Text("\(vm.description.count) karakter")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(14)
            .background(Color(.systemBackground))
        }
    }

    var bottomCreateButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    let success = await vm.createLeave()

                    if success {
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

                    Text(vm.isLoading ? "Oluşturuluyor..." : "İzin Oluştur")
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
}

// MARK: - UI Helpers

@available(iOS 17.0, *)
private extension CreateLeaveView {

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

    func inputRow(
        title: String,
        text: Binding<String>,
        icon: String,
        placeholder: String
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

    func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(14)
        .background(Color.red.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.20), lineWidth: 1)
        )
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
