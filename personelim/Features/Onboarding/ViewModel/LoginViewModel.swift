//
//  LoginViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 2.12.2025.
//

import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false   // Dışarıdan dinleyebilirsin
    
    private let network: NetworkManagerProtocol
    
    init(network: NetworkManagerProtocol = NetworkManager()) {
        self.network = network
    }
    
    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email ve şifre zorunludur."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = LoginRequest(email: email, password: password)
        
        do {
            let response = try await network.login(request)
            
            if response.success, let user = response.data {
                // Token ve kullanıcı bilgilerini kaydet
                UserDefaults.standard.set(user.token, forKey: "auth_token")
                UserDefaults.standard.set(user.fullName, forKey: "full_name")
                UserDefaults.standard.set(user.email, forKey: "user_email")
                UserDefaults.standard.set(user.userId, forKey: "user_id")
                UserDefaults.standard.set(user.expiresAt, forKey: "token_expires_at")
                
                // rememberMe’ye göre belki ileride email’i de saklayabilirsin
                if rememberMe {
                    UserDefaults.standard.set(email, forKey: "remember_email")
                }
                
                isLoggedIn = true
            } else {
                errorMessage = response.message ?? "Giriş başarısız."
            }
        } catch {
            errorMessage = "Sunucuya bağlanırken bir hata oluştu."
            print("Login error:", error)
        }
        
        isLoading = false
    }
}
