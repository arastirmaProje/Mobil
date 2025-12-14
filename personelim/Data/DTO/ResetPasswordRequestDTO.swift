//
//  ResetPasswordRequestDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 7.12.2025.
//

import Foundation

struct ResetPasswordRequestDTO: Encodable {
    let email: String
    let code: String
    let newPassword: String
    let confirmPassword: String
}
