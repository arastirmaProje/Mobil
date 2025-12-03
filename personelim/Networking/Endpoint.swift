//
//  Endpoint.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

enum Endpoint {
    case login

    var path: String {
        switch self {
        case .login:
            return "/api/Auth/login"
        }
    }
}
