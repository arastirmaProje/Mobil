//
//  EmailVerifyView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 24.11.2025.
//

import SwiftUI

struct EmailVerifyView: View {
    
    let email: String
    let onCodeEntered: (String) -> Void
    
    @State private var code = ""
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Email Doğrulama")
                .font(.title2.bold())
                .padding(.top, 32)
            
            Text("\(email) adresine gönderilen doğrulama kodunu giriniz.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            OTPInputView(code: $code) { otp in
                onCodeEntered(otp)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct EmailVerifyView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerifyView(email: "test@example.com") { _ in }
    }
}
