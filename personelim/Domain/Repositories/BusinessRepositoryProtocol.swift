//
//  BusinessRepositoryProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//


import Foundation

protocol BusinessRepositoryProtocol {

    func createBusiness(request: CreateBusinessRequestDTO) async throws
    func createBusinessAndReturnId(request: CreateBusinessRequestDTO) async throws -> String
    func getBusiness(businessId: String) async throws -> BusinessDTO
    func verifyBusiness(code: String) async throws -> VerifyBusinessResponseDTO
    func getMyBusiness() async throws -> BusinessDTO
    func getBusinesses() async throws -> [BusinessDTO]
    func updateBusiness(businessId: String, request: UpdateBusinessRequestDTO) async throws -> EmptyResponse

}
