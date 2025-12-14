//
//  SignupView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 7.12.2025.
//

import SwiftUI

struct SignupView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = SignupViewModel()

    var body: some View {
        VStack(spacing: 0) {

            header

            ScrollView {
                VStack(spacing: 24) {

                    topAnimationBox

                    Text("Kayıt olun")
                        .font(.title2.weight(.semibold))
                        .padding(.top, 8)

                    formFields

                    signupButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(edges: .top)

        // MARK: - ERROR
        .alert(isPresented: $vm.showError) {
            Alert(
                title: Text("Hata"),
                message: Text(vm.errorMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }

        // MARK: - EMAIL VERIFY
        .fullScreenCover(isPresented: $vm.goToVerifyEmail) {
            EmailVerifyView(
                email: vm.registeredEmail
            ) { code in
                print("Girilen doğrulama kodu:", code)
                // 🔜 VerifyEmailUseCase burada bağlanacak
            }
        }
    }
}

// MARK: - UI PARTS
extension SignupView {

    // HEADER
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // ANIMATION PLACEHOLDER
    private var topAnimationBox: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(UIColor.systemGray5))
            .frame(height: 150)
            .overlay(
                Text("Spline / Lottie animasyonu\nburaya eklenebilir.")
                    .multilineTextAlignment(.center)
            )
    }

    // FORM
    private var formFields: some View {
        VStack(alignment: .leading, spacing: 18) {

            customTextField("Ad", "Name", $vm.firstName)
            customTextField("Soyad", "Surname", $vm.lastName)
            customTextField("Email", "damn@gmail.com", $vm.email)
                .keyboardType(.emailAddress)
            customSecureField("Şifre", "123...", $vm.password)
        }
    }

    // BUTTON
    private var signupButton: some View {
        Button {
            Task { await vm.register() }
        } label: {
            Text(vm.isLoading ? "Kayıt yapılıyor..." : "Devam et")
        }
        .disabled(vm.isLoading)
        .buttonStyle(OnboardingButtonStyle())
        .padding(.top, 8)
    }

    // COMPONENTS
    private func customTextField(
        _ title: String,
        _ placeholder: String,
        _ text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
            TextField(placeholder, text: text)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.systemGray4))
                )
        }
    }

    private func customSecureField(
        _ title: String,
        _ placeholder: String,
        _ text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
            SecureField(placeholder, text: text)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.systemGray4))
                )
        }
    }
}
