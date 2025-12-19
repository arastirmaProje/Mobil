//
//  AuthModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

struct RegisterUserEntity {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
}

struct AuthUserEntity {
    let userId: String
    let email: String
    let fullName: String
    let token: String
    let expiresAt: String
    let role: UserRole
}

struct ForgotPasswordResponseEntity {
    let email: String
    let expiresAt: String
    let expiresInMinutes: Int
}
