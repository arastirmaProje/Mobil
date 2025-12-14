//
//  ForgotPasswordViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var code: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var codeSent = false
    @Published var showResetPassword = false
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepositoryImpl(network: NetworkManager())) {
        self.authRepository = authRepository
    }
    
    // MARK: - SEND RESET CODE
    func sendCode() async {
        guard !email.isEmpty else {
            errorMessage = "Email gereklidir."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authRepository.forgotPassword(email: email)
            print("📩 Reset code expires in: \(response.expiresInMinutes)")
            codeSent = true
        } catch let error as RepositoryError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Kod gönderilemedi. Lütfen tekrar deneyin."
        }
        
        isLoading = false
    }
    
    // MARK: - VERIFY RESET CODE
    func verifyCode() async {
        guard code.count == 6 else {
            errorMessage = "Kod 6 haneli olmalıdır."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let isValid = try await authRepository.verifyResetCode(email: email, code: code)
            
            if isValid {
                showResetPassword = true
            } else {
                errorMessage = "Kod doğrulanamadı."
            }
            
        } catch let error as RepositoryError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Kod doğrulanırken bir hata oluştu."
        }
        
        isLoading = false
    }
}
