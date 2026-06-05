import SwiftUI

struct SignupView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @StateObject private var vm = SignupViewModel()

    @State private var showPassword = false

    private var canContinue: Bool {
        !vm.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !vm.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        vm.email.contains("@") &&
        !vm.password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
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

                        infoCard

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomContinueButton
            }
            .navigationTitle(ConstantStrings.signupTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .scrollDismissesKeyboard(.interactively)
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
            .navigationDestination(isPresented: $vm.goToCreateCompany) {
                CreateCompanyView {
                    if let user = vm.createdUser {
                        let dto = UserProfileDTO(
                            id: user.userId,
                            email: user.email,
                            firstName: nil,
                            lastName: nil,
                            fullName: user.fullName,
                            phoneNumber: nil,
                            createdAt: nil,
                            lastLoginAt: nil,
                            businessCount: nil,
                            ownedBusinessCount: nil,
                            imageUrl: nil
                        )

                        appState.applyLogin(
                            userDTO: dto,
                            role: user.role
                        )
                    }
                }
            }
            .alert(ConstantStrings.errorTitle, isPresented: $vm.showError) {
                Button(ConstantStrings.okButton, role: .cancel) { }
            } message: {
                Text(vm.errorMessage)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 84, height: 84)

            VStack(spacing: 6) {
                Text(ConstantStrings.signupTitle)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Önce hesabını oluştur, ardından şirket bilgilerini tamamla.")
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
        sectionCard(title: "Hesap Bilgileri") {
            inputRow(
                title: ConstantStrings.firstNameLabel,
                placeholder: ConstantStrings.firstNamePlaceholder,
                text: $vm.firstName,
                icon: "person.fill",
                autocapitalization: .words
            )

            inputRow(
                title: ConstantStrings.lastNameLabel,
                placeholder: ConstantStrings.lastNamePlaceholder,
                text: $vm.lastName,
                icon: "person.text.rectangle.fill",
                autocapitalization: .words
            )

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
                        TextField(ConstantStrings.passwordPlaceholderSignup, text: $vm.password)
                    } else {
                        SecureField(ConstantStrings.passwordPlaceholderSignup, text: $vm.password)
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

    // MARK: - Info

    private var infoCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Sonraki adım")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Kayıttan sonra şirket oluşturma ekranına yönlendirileceksin.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.blue.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Bottom

    private var bottomContinueButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    await vm.register()
                }
            } label: {
                HStack(spacing: 8) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                    }

                    Text(vm.isLoading ? "Kaydediliyor..." : ConstantStrings.continueButton)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canContinue ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canContinue)
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
