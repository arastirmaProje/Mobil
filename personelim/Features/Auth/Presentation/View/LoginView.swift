import SwiftUI

struct LoginView: View {

    @StateObject private var vm = LoginViewModel()

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @State private var goToResetPassword = false
    @State private var showPassword = false

    private var canLogin: Bool {
        !vm.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !vm.password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        vm.email.contains("@") &&
        !vm.isLoading
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

                        rememberForgotSection

                        if let error = vm.errorMessage {
                            errorCard(error)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomLoginButton
            }
            .navigationTitle(ConstantStrings.loginTitle)
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
            .navigationDestination(isPresented: $goToResetPassword) {
                ForgotPasswordView()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 84, height: 84)

            VStack(spacing: 6) {
                Text(ConstantStrings.loginTitle)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Hesabına giriş yaparak personel yönetimine devam et.")
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
        sectionCard(title: "Giriş Bilgileri") {
            inputRow(
                title: ConstantStrings.emailLabel,
                placeholder: ConstantStrings.emailPlaceholder,
                text: $vm.email,
                icon: "envelope.fill",
                keyboard: .emailAddress,
                autocapitalization: .never
            )

            passwordRow
        }
    }

    private var passwordRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.passwordLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Group {
                    if showPassword {
                        TextField("123...", text: $vm.password)
                    } else {
                        SecureField("123...", text: $vm.password)
                    }
                }
                .font(.system(size: 15, weight: .medium))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }

            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .formRowBackground()
    }

    // MARK: - Remember / Forgot

    private var rememberForgotSection: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    vm.rememberMe.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: vm.rememberMe ? "checkmark.square.fill" : "square")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(vm.rememberMe ? Color.blue : Color.secondary)

                    Text(ConstantStrings.rememberMe)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                goToResetPassword = true
            } label: {
                Text(ConstantStrings.forgotPasswordTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 2)
    }

    // MARK: - Bottom Button

    private var bottomLoginButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    await vm.login(appState: appState)
                }
            } label: {
                HStack(spacing: 8) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                    }

                    Text(vm.isLoading ? "Giriş yapılıyor..." : ConstantStrings.loginButton)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canLogin ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canLogin)
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

    private func inputRow(
        title: String,
        placeholder: String,
        text: Binding<String>,
        icon: String,
        keyboard: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization? = .sentences
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
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled()
            }
        }
        .formRowBackground()
    }

    private func errorCard(_ message: String) -> some View {
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
