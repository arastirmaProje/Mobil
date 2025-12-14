//
//  BusinessRepositoryProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

protocol BusinessRepositoryProtocol {
    
    /// Şirket oluşturma
    func createBusiness(request: CreateBusinessRequestDTO) async throws
    
    /// Şirket email / kod doğrulama
    func verifyBusiness(code: String) async throws
    
    /// Şirket bilgilerini profil sayfasına çekmek için şimdlik kullanmıyoruz sonra diğer filelar eklendikten sonra kullanıma açarız.
    //func getBusiness(businessId: String) async throws -> BusinessProfileEntity
}
