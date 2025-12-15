//
//  TokenStore.swift
//  personelim
//
//  Created by Tuğberk Acabey on 15.12.2025.
//

import Foundation

final class TokenStore {

    static let shared = TokenStore()
    private init() {}

    private let tokenKey = "auth_token"

    var token: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    func save(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }

    func hasValidToken() -> Bool {
        token != nil
    }
}
