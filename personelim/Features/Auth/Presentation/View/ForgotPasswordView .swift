//
//  ForgotPasswordView .swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @StateObject private var vm = ForgotPasswordViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Title
            Text("Şifremi unuttum")
                .font(.title2.weight(.semibold))
                .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 24) {
                
                // Email Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                    
                    TextField("ornek@gmail.com", text: $vm.email)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        )
                }
                
                // OTP Input (6 Digit)
                if vm.codeSent {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Kodu Gir")
                            .font(.system(size: 14, weight: .medium))

                        OTPInputView(code: $vm.code) { otp in
                            Task { await vm.verifyCode() }
                        }
                    }
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // Send Code Button
            Button(vm.codeSent ? "Tekrar Gönder" : "Kod Gönder") {
                Task { await vm.sendCode() }
            }
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
        }
        .fullScreenCover(isPresented: $vm.showResetPassword) {
            ResetPasswordView(email: vm.email, code: vm.code)
        }
        .onChange(of: vm.errorMessage) { err in
            if let err = err { print("⚠️ ERROR:", err) }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Preview
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForgotPasswordView()
                .previewDevice("iPhone 15 Pro")
            
            ForgotPasswordView()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
