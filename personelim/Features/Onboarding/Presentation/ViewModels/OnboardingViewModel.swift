//
//  OnboardingViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 7.12.2025.
//

import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Navigation States
    @Published var showLogin: Bool = false
    @Published var showRegister: Bool = false
    
    init() {}
    
    // MARK: - Actions
    func loginTapped() {
        showLogin = true
    }
    
    func createCompanyTapped() {
        showRegister = true
    }
}
