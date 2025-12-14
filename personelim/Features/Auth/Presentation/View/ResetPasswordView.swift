//
//  ResetPasswordView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 24.11.2025.
//

import SwiftUI

struct ResetPasswordView: View {

    let email: String
    let code: String

    @StateObject private var vm: ResetPasswordViewModel

    init(email: String, code: String) {
        self.email = email
        self.code = code
        _vm = StateObject(wrappedValue: ResetPasswordViewModel(email: email, code: code))
    }

    var body: some View {
        VStack(spacing: 0) {

            Text("Şifremi unuttum")
                .font(.title2.weight(.semibold))
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 16) {

                Text("Yeni Şifre")
                SecureField("Yeni şifre", text: $vm.newPassword)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))

                Text("Yeni Şifre Tekrar")
                SecureField("Tekrar yeni şifre", text: $vm.confirmPassword)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            Button("Onayla") {
                Task { await vm.resetPassword() }
            }
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .alert(isPresented: $vm.showError) {
            Alert(
                title: Text("Hata"),
                message: Text(vm.errorMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
// MARK: - Preview
struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ResetPasswordView(email: "test@gmail.com", code: "123456")
                .previewDevice("iPhone 16 Pro")
            
            ResetPasswordView(email: "test@gmail.com", code: "123456")
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
