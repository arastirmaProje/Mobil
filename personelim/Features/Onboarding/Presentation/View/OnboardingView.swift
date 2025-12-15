//
//  OnboardingView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 22.11.2025.
//

import SwiftUI

struct OnboardingView: View {

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Text("Personelim")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 32)

                Spacer()

                VStack(spacing: 12) {

                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Giriş Yap")
                    }
                    .buttonStyle(OnboardingButtonStyle())

                    NavigationLink {
                        SignupView()
                    } label: {
                        Text("Şirket oluştur")
                    }
                    .buttonStyle(OnboardingButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Button Style
struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color(UIColor.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
