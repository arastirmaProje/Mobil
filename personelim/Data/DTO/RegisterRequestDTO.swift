//
//  RegisterRequestDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

struct RegisterRequestDTO: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
}
