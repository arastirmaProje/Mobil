//
//  BusinessRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

final class BusinessRepositoryImpl: BusinessRepositoryProtocol {

    // MARK: - Dependency
    private let networkManager: NetworkManagerProtocol

    // MARK: - Init
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    // MARK: - Create Business
    func createBusiness(request: CreateBusinessRequestDTO) async throws {

        // Swagger: response body yok → EmptyResponse
        let _: EmptyResponse = try await networkManager.request(
            endpoint: .createBusiness,
            method: .post,
            body: request
        )
    }

    // MARK: - Verify Business (Email / Code)
    func verifyBusiness(code: String) async throws {

        let body = VerifyBusinessRequestDTO(code: code)

        let _: EmptyResponse = try await networkManager.request(
            endpoint: .verifyBusiness,
            method: .post,
            body: body
        )
    }
}
