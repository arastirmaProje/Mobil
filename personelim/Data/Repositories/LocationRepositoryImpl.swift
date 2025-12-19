//
//  LocationRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

final class LocationRepositoryImpl: LocationRepositoryProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    func getProvinces() async throws -> [ProvinceDTO] {
        let data: [ProvinceDTO] = try await network.request(
            endpoint: .provinces,
            method: .get,
            body: nil
        )
        return data
    }

    func getDistricts(provinceId: Int) async throws -> [DistrictDTO] {
        let data: [DistrictDTO] = try await network.request(
            endpoint: .districts(provinceId: provinceId),
            method: .get,
            body: nil
        )
        return data
    }
}
