//
//  SignupView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 7.12.2025.
//

import SwiftUI

struct SignupView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = SignupViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Custom Top Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // MARK: - CONTENT
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            Text("Kayıt olun")
                                .font(.title2.weight(.semibold))
                                .padding(.top, 8)
                            
                            formFields
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 120)
                    }
                }
                
                // MARK: - BOTTOM BUTTON
                VStack {
                    Spacer()
                    
                    Button {
                        Task { await vm.register() }
                    } label: {
                        Text("Devam et")
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .disabled(vm.isLoading)
                    .buttonStyle(OnboardingButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .background(Color.white)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        
        // MARK: - NAVIGATION
        .navigationDestination(isPresented: $vm.goToCreateCompany) {
            CreateCompanyView {
                guard let u = vm.createdUser else { return }
                appState.applyLogin(userId: u.userId, role: u.role)
            }
        }

        // MARK: - ERROR
        .alert("Hata", isPresented: $vm.showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }
}

// MARK: - FORM
private extension SignupView {

    var formFields: some View {
        VStack(alignment: .leading, spacing: 18) {

            labeledTextField(
                title: "Ad",
                placeholder: "Adınız",
                text: $vm.firstName
            )

            labeledTextField(
                title: "Soyad",
                placeholder: "Soyadınız",
                text: $vm.lastName
            )

            labeledTextField(
                title: "Email",
                placeholder: "ornek@gmail.com",
                text: $vm.email
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)

            labeledSecureField(
                title: "Şifre",
                placeholder: "••••••",
                text: $vm.password
            )
        }
    }

    func labeledTextField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))

            TextField(placeholder, text: text)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                )
        }
    }

    func labeledSecureField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))

            SecureField(placeholder, text: text)
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                )
        }
    }
}
