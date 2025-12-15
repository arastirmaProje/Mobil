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
            
            // MARK: - CONTENT
            VStack(spacing: 0) {
                
                // TOP BAR
                topBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        Text("Kayıt olun")
                            .font(.title2.weight(.semibold))
                            .padding(.top, 8)
                        
                        formFields
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 120) // bottom button için boşluk
                }
            }
            
            // MARK: - BOTTOM BUTTON
            VStack {
                Spacer()
                
                Button {
                    Task { await vm.register() }
                } label: {
                    Text(vm.isLoading ? "Kayıt yapılıyor..." : "Devam et")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .disabled(vm.isLoading)
                .buttonStyle(OnboardingButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .background(Color.white)
            }
        }
        .navigationBarBackButtonHidden(true)
        
        // MARK: - NAVIGATION
        .navigationDestination(isPresented: $vm.goToCreateCompany) {
            CreateCompanyView {
                appState.login()
            }
            .onAppear {
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

// MARK: - TOP BAR
private extension SignupView {
    
    var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Circle())
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 6)
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
