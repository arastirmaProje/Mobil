//
//  ResetPasswordView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 24.11.2025.
//

import SwiftUI

struct ResetPasswordView: View {
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text("Şifremi unuttum")
                .font(.title2.weight(.semibold))
                .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Yeni Şifre")
                TextField("...", text: $newPassword)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))

                Text("Yeni Şifre Tekrar")
                TextField("...", text: $confirmPassword)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            Button("Onayla") {
                // → Şifre reset api
            }
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
// MARK: - Preview
struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ResetPasswordView()
                .previewDevice("iPhone 16 Pro")
            
            ResetPasswordView()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
