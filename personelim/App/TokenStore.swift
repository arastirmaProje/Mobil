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
    private let selectedBusinessIdKey = "selected_business_id"

    var token: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    func save(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    var selectedBusinessId: String? {
        get { UserDefaults.standard.string(forKey: selectedBusinessIdKey) }
        set {
            if let v = newValue {
                UserDefaults.standard.set(v, forKey: selectedBusinessIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: selectedBusinessIdKey)
            }
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: selectedBusinessIdKey)
    }

    func hasValidToken() -> Bool {
        token != nil
    }
}
