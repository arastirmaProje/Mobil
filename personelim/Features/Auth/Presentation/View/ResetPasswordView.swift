import SwiftUI

struct ResetPasswordView: View {

    let email: String
    let code: String

    @StateObject private var vm: ResetPasswordViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showNewPassword = false
    @State private var showConfirmPassword = false

    init(email: String, code: String) {
        self.email = email
        self.code = code

        _vm = StateObject(
            wrappedValue: ResetPasswordViewModel(
                email: email,
                code: code
            )
        )
    }

    private var canSubmit: Bool {
        !vm.newPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !vm.confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        vm.newPassword == vm.confirmPassword
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection

                        formSection

                        passwordInfoCard

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomConfirmButton
            }
            .navigationTitle(ConstantStrings.resetPasswordTitle)
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
            .alert(isPresented: $vm.showError) {
                Alert(
                    title: Text(ConstantStrings.leaveErrorTitle),
                    message: Text(vm.errorMessage),
                    dismissButton: .default(Text(ConstantStrings.okButton))
                )
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 82, height: 82)

            VStack(spacing: 6) {
                Text(ConstantStrings.resetPasswordTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Yeni şifreni belirleyerek hesabına tekrar giriş yapabilirsin.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Form

    private var formSection: some View {
        sectionCard(title: "Yeni Şifre") {
            passwordRow(
                title: ConstantStrings.newPasswordLabel,
                placeholder: ConstantStrings.newPasswordPlaceholder,
                text: $vm.newPassword,
                isVisible: $showNewPassword
            )

            passwordRow(
                title: ConstantStrings.confirmPasswordLabel,
                placeholder: ConstantStrings.confirmPasswordPlaceholder,
                text: $vm.confirmPassword,
                isVisible: $showConfirmPassword
            )
        }
    }

    private func passwordRow(
        title: String,
        placeholder: String,
        text: Binding<String>,
        isVisible: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Group {
                    if isVisible.wrappedValue {
                        TextField(placeholder, text: text)
                    } else {
                        SecureField(placeholder, text: text)
                    }
                }
                .font(.system(size: 15, weight: .medium))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }

            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(systemName: isVisible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .formRowBackground()
    }

    // MARK: - Info

    private var passwordInfoCard: some View {
        HStack(spacing: 12) {
            Image(systemName: passwordInfoIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(passwordInfoColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(passwordInfoTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)

                Text(passwordInfoText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(passwordInfoColor.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(passwordInfoColor.opacity(0.18), lineWidth: 1)
        )
    }

    private var passwordInfoIcon: String {
        if vm.newPassword.isEmpty && vm.confirmPassword.isEmpty {
            return "info.circle.fill"
        }

        return vm.newPassword == vm.confirmPassword
            ? "checkmark.circle.fill"
            : "exclamationmark.triangle.fill"
    }

    private var passwordInfoColor: Color {
        if vm.newPassword.isEmpty && vm.confirmPassword.isEmpty {
            return .blue
        }

        return vm.newPassword == vm.confirmPassword ? .green : .orange
    }

    private var passwordInfoTitle: String {
        if vm.newPassword.isEmpty && vm.confirmPassword.isEmpty {
            return "Şifre bilgisi"
        }

        return vm.newPassword == vm.confirmPassword
            ? "Şifreler eşleşiyor"
            : "Şifreler eşleşmiyor"
    }

    private var passwordInfoText: String {
        if vm.newPassword.isEmpty && vm.confirmPassword.isEmpty {
            return "Yeni şifreni iki alana da gir."
        }

        return vm.newPassword == vm.confirmPassword
            ? "Şifreni değiştirmek için onaylayabilirsin."
            : "Devam etmek için iki şifre alanı aynı olmalı."
    }

    // MARK: - Bottom

    private var bottomConfirmButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    await vm.resetPassword()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")

                    Text(ConstantStrings.confirmButton)
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

    // MARK: - Helpers

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
