//
//  GetProvincesUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

protocol GetProvincesUseCaseProtocol {
    func execute() async throws -> [ProvinceDTO]
}

final class GetProvincesUseCase: GetProvincesUseCaseProtocol {

    private let repo: LocationRepositoryProtocol
    init(repo: LocationRepositoryProtocol = LocationRepositoryImpl(network: NetworkManager())) {
        self.repo = repo
    }

    func execute() async throws -> [ProvinceDTO] {
        try await repo.getProvinces()
    }
}
