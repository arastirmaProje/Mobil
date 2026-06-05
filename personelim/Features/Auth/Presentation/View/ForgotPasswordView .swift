import SwiftUI

struct ForgotPasswordView: View {

    @StateObject private var vm = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss

    private var canSendCode: Bool {
        let email = vm.email.trimmingCharacters(in: .whitespacesAndNewlines)
        return email.contains("@") && email.contains(".")
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

                        if vm.codeSent {
                            codeSection
                        }

                        if let error = vm.errorMessage {
                            messageCard(
                                message: error,
                                icon: "exclamationmark.triangle.fill",
                                color: .red
                            )
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomActionButton
            }
            .navigationTitle(ConstantStrings.forgotPasswordTitle)
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
            .fullScreenCover(isPresented: $vm.showResetPassword) {
                ResetPasswordView(
                    email: vm.email,
                    code: vm.code
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

                Image(systemName: "lock.rotation")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 82, height: 82)

            VStack(spacing: 6) {
                Text(ConstantStrings.forgotPasswordTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Şifreni sıfırlamak için e-posta adresine doğrulama kodu göndereceğiz.")
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
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
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

    // MARK: - Code

    private var codeSection: some View {
        sectionCard(title: ConstantStrings.enterCode) {
            VStack(spacing: 14) {
                OTPInputView(code: $vm.code) { _ in
                    Task {
                        await vm.verifyCode()
                    }
                }

                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.blue)

                    Text("Kod tamamlandığında doğrulama otomatik başlar.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding(12)
                .background(Color.blue.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(14)
            .background(Color(.systemBackground))
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Bottom

    private var bottomActionButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    await vm.sendCode()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: vm.codeSent ? "arrow.clockwise.circle.fill" : "paperplane.fill")

                    Text(vm.codeSent ? ConstantStrings.resendCode : ConstantStrings.sendCode)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canSendCode ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canSendCode)
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
