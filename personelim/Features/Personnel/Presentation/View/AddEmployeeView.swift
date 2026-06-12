import SwiftUI

struct AddEmployeeView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    private let network = NetworkManager()

    private var memberRepo: BusinessMemberRepositoryProtocol {
        BusinessMemberRepositoryImpl(network: network)
    }

    @StateObject private var vm: AddEmployeeViewModel

    init() {
        let useCase = SendInvitationUseCase(
            repo: InvitationRepositoryImpl(network: NetworkManager())
        )

        _vm = StateObject(
            wrappedValue: AddEmployeeViewModel(sendUseCase: useCase)
        )
    }

    private var isValidEmail: Bool {
        let value = vm.email.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.contains("@") && value.contains(".")
    }

    private var canSubmit: Bool {
        isValidEmail && !vm.isLoading && appState.businessId != nil
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection

                        emailSection

                        if vm.isLoading {
                            loadingCard
                        }

                        if let error = vm.errorMessage {
                            messageCard(
                                message: error,
                                icon: "exclamationmark.triangle.fill",
                                color: .red
                            )
                        }

                        if let success = vm.successMessage {
                            messageCard(
                                message: success,
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomSendButton
            }
            .navigationTitle(ConstantStrings.addEmployeeTitle)
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
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "paperplane.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.addEmployeeTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.addEmployeeDescription)
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

    // MARK: - Email

    private var emailSection: some View {
        sectionCard(title: ConstantStrings.emailLabel) {
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 5) {
                    Text(ConstantStrings.emailLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    TextField(ConstantStrings.emailPlaceholder, text: $vm.email)
                        .font(.system(size: 15, weight: .medium))
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }

                if !vm.email.isEmpty {
                    Button {
                        vm.email = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .formRowBackground()
        }
    }

    // MARK: - Loading / Messages

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.invitationSendingLoading)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func messageCard(
        message: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(message)
                .font(.caption)
                .foregroundStyle(color)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(14)
        .background(color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(color.opacity(0.20), lineWidth: 1)
        )
    }

    // MARK: - Bottom Button

    private var bottomSendButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    guard let businessId = appState.businessId else { return }

                    await vm.send(businessId: businessId)

                    if vm.errorMessage == nil, vm.successMessage != nil {
                        await appState.refreshBusinessMembers(repository: memberRepo)
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }

                    Text(vm.isLoading ? ConstantStrings.sendButtonLoading : ConstantStrings.sendInvitation)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canSubmit ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }

    // MARK: - UI Helpers

    private func sectionCard<Content: View>(
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
