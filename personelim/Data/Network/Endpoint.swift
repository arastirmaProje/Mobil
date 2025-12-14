//
//  Endpoint.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

enum Endpoint {
    case login
    case register
    case forgotPassword
    case verifyResetCode
    case resetPassword
    case verifyBusiness
    case createBusiness
    
    var path: String {
        switch self {
        case .login: return "/api/Auth/login"
        case .register: return "/api/Auth/register"
        case .forgotPassword: return "/api/Auth/forgot-password"
        case .verifyResetCode: return "/api/Auth/verify-reset-code"
        case .resetPassword: return "/api/Auth/reset-password"
        case .verifyBusiness: return "/api/Business/verify"
        case .createBusiness: return "/api/Business/create-business"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .forgotPassword, .verifyResetCode, .resetPassword, .verifyBusiness,  .createBusiness: return .post
        }
    }
}
