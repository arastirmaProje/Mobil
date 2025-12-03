//
//  ForgotPasswordView .swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @State private var email = ""
    @State private var code = ""
    @State private var showResetPassword = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Back Button
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Title
            Text("Şifremi unuttum")
                .font(.title2.weight(.semibold))
                .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 24) {
                
                // Email Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                    
                    TextField("damn@gmail.com", text: $email)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        )
                }
                
                // OTP Input (6 Digit)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Kodu Gir")
                        .font(.system(size: 14, weight: .medium))

                    OTPInputView(code: $code) { otp in
                        print("Girilen Kod: \(otp)")
                        showResetPassword = true
                    }
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // Send Code Button
            Button("Kod gönder") {
                // → Email ile forgot-password isteği viewmodel ile atılacak
            }
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
        }
        .fullScreenCover(isPresented: $showResetPassword) {
            ResetPasswordView()
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
