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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Text("Kayıt olun")
                            .font(.title2.weight(.semibold))
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 18) {

                            Text("Ad")
                                .font(.system(size: 14, weight: .medium))
                            TextField("Adınız", text: $vm.firstName)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                )

                            Text("Soyad")
                                .font(.system(size: 14, weight: .medium))
                            TextField("Soyadınız", text: $vm.lastName)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                )

                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                            TextField("ornek@gmail.com", text: $vm.email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                )

                            Text("Şifre")
                                .font(.system(size: 14, weight: .medium))
                            SecureField("••••••", text: $vm.password)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 140)
                }

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

        .navigationDestination(isPresented: $vm.goToCreateCompany) {
            CreateCompanyView {
                if let u = vm.createdUser {
                    let dto = UserProfileDTO(
                        id: u.userId,
                        email: u.email,
                        firstName: nil,
                        lastName: nil,
                        fullName: u.fullName,
                        phoneNumber: nil,
                        createdAt: nil,
                        lastLoginAt: nil,
                        businessCount: nil,
                        ownedBusinessCount: nil,
                        imageUrl: nil
                    )
                    appState.applyLogin(
                        userDTO: dto,
                        role: u.role
                    )
                }
            }
        }

        .alert("Hata", isPresented: $vm.showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }
}

