//
//  OnboardingView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 22.11.2025.
//

import SwiftUI

struct OnboardingView: View {
    
    @StateObject private var vm = OnboardingViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            welcomeText
            
            Spacer()
            
            actionButtons
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.bottom, Layout.bottomPadding)
        }
        .fullScreenCover(isPresented: $vm.showLogin) {
            LoginView()
        }
        .fullScreenCover(isPresented: $vm.showRegister) {
            SignupView()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Subviews
private extension OnboardingView {
    
    var welcomeText: some View {
        Text("Personelim")
            .font(.title2.weight(.semibold))
            .padding(.top, Layout.topPadding)
    }
    
    var actionButtons: some View {
        VStack(spacing: Layout.buttonSpacing) {
            
            Button("Giriş Yap") {
                vm.loginTapped()
            }
            .buttonStyle(OnboardingButtonStyle())
            
            Button("Şirket oluştur") {
                vm.createCompanyTapped()
            }
            .buttonStyle(OnboardingButtonStyle())
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

// MARK: - Layout Constants
private struct Layout {
    static let topPadding: CGFloat = 32
    static let bottomPadding: CGFloat = 24
    static let horizontalPadding: CGFloat = 20
    static let buttonSpacing: CGFloat = 12
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView()
                .previewDevice("iPhone 16 Pro")
            
            OnboardingView()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
