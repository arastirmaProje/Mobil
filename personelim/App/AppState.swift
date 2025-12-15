//
//  AppState.swift
//  personelim
//
//  Created by Tuğberk Acabey on 15.12.2025.
//

import Foundation

@MainActor
final class AppState: ObservableObject {

    @Published private(set) var isLoggedIn: Bool = false

    init() {
        isLoggedIn = TokenStore.shared.hasValidToken()
    }

    func login() {
        isLoggedIn = true
    }

    func logout() {
        TokenStore.shared.clear()
        isLoggedIn = false
    }
}
