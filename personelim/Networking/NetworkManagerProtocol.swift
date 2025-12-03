//
//  NetworkManagerProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import Foundation

protocol NetworkManagerProtocol {
    /// Login isteği atar ve AuthResponse döner
    func login(_ request: LoginRequest) async throws -> AuthResponse
}
