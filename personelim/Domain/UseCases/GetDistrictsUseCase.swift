//
//  GetDistrictsUseCase.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

protocol GetDistrictsUseCaseProtocol {
    func execute(provinceId: Int) async throws -> [DistrictDTO]
}

final class GetDistrictsUseCase: GetDistrictsUseCaseProtocol {

    private let repo: LocationRepositoryProtocol
    init(repo: LocationRepositoryProtocol = LocationRepositoryImpl(network: NetworkManager())) {
        self.repo = repo
    }

    func execute(provinceId: Int) async throws -> [DistrictDTO] {
        try await repo.getDistricts(provinceId: provinceId)
    }
}
