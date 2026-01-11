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

                // MARK: - Back Button
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

                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        Text(ConstantStrings.signupTitle)
                            .font(.title2.weight(.semibold))
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 18) {

                            Text(ConstantStrings.firstNameLabel)
                                .font(.system(size: 14, weight: .medium))
                            TextField(ConstantStrings.firstNamePlaceholder, text: $vm.firstName)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                )

                            Text(ConstantStrings.lastNameLabel)
                                .font(.system(size: 14, weight: .medium))
                            TextField(ConstantStrings.lastNamePlaceholder, text: $vm.lastName)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                )

                            Text(ConstantStrings.emailLabel)
                                .font(.system(size: 14, weight: .medium))
                            TextField(ConstantStrings.emailPlaceholder, text: $vm.email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                )

                            Text(ConstantStrings.passwordLabel)
                                .font(.system(size: 14, weight: .medium))
                            SecureField(ConstantStrings.passwordPlaceholderSignup, text: $vm.password)
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

                // MARK: - Bottom Button
                VStack {
                    Spacer()
                    Button {
                        Task { await vm.register() }
                    } label: {
                        Text(ConstantStrings.continueButton)
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

        // MARK: - Navigation
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

        // MARK: - Error Alert
        .alert(ConstantStrings.errorTitle, isPresented: $vm.showError) {
            Button(ConstantStrings.okButton, role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }
}
