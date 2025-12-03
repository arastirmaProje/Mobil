//
//  CreateCompanyViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 24.11.2025.
//

import SwiftUI

final class CreateCompanyViewModel: ObservableObject {
    
    // MARK: - Company Info
    @Published var companyName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    // MARK: - Address Info
    @Published var selectedCity: String = ""
    @Published var selectedDistrict: String = ""
    @Published var detailedAddress: String = ""
    @Published var phone: String = ""
    @Published var description: String = ""
    
    // MARK: - Offices
    @Published var offices: [Office] = []
    
    // MARK: - City/District Data (şimdilik mock)
    let cities = ["İstanbul", "Ankara", "İzmir"]
    
    let districts: [String: [String]] = [
        "İstanbul": ["Kadıköy", "Üsküdar", "Beşiktaş", "Esenyurt"],
        "Ankara": ["Çankaya", "Keçiören", "Mamak"],
        "İzmir": ["Bornova", "Konak", "Karşıyaka"]
    ]
    
    // MARK: - UI Helper
    var showDistricts: Bool {
        !selectedCity.isEmpty
    }
    
    // MARK: - Office Logic
    func addOffice() {
        let nextIndex = offices.count + 1
        offices.append(Office(index: nextIndex, address: ""))
    }
    
    func removeLastOffice() {
        guard !offices.isEmpty else { return }
        offices.removeLast()
    }
    
    // MARK: - VALIDATION
    func isFormValid() -> Bool {
        !companyName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !selectedCity.isEmpty &&
        !selectedDistrict.isEmpty
    }
    
    // MARK: - API Action (şimdilik stub)
    func createCompany(completion: @escaping (Bool) -> Void) {
        
        guard isFormValid() else {
            completion(false)
            return
        }
        
        print("API’ye gönderilecek data:")
        print("""
        CompanyName: \(companyName)
        Email: \(email)
        Password: \(password)
        City: \(selectedCity)
        District: \(selectedDistrict)
        DetailedAddress: \(detailedAddress)
        Phone: \(phone)
        Description: \(description)
        Offices: \(offices.map { $0.address })
        """)
        
        // Burada Network katmanına bağlanacağız:
        // 1) /api/Auth/register
        // 2) /api/Business (şirket oluşturma)
        completion(true)
    }
    
    // MARK: - OTP Doğrulama + Şirket Oluşturma
    func verifyOTPAndCreateCompany(otp: String, completion: @escaping (Bool) -> Void) {
        // Şimdilik demo: 6 haneli herhangi bir kodu doğru kabul edelim
        guard otp.count == 6 else {
            completion(false)
            return
        }
        
        // Sonraki adımda buraya gerçek /api/Auth/verify-reset-code veya
        // backend'in sağlayacağı email doğrulama endpoint'ini bağlarız.
        
        createCompany(completion: completion)
    }
}
