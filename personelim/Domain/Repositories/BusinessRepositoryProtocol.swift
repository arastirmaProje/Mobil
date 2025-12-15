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

    /// Şirket email / kod doğrulama (true = başarılı)
    func verifyBusiness(code: String) async throws -> VerifyBusinessResponseDTO
    
    /// Şirket bilgilerini profil sayfasına çekmek için şimdlik kullanmıyoruz sonra diğer filelar eklendikten sonra kullanıma açarız.
    //func getBusiness(businessId: String) async throws -> BusinessProfileEntity
}
