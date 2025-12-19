//
//  LocationRepositoryProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

protocol LocationRepositoryProtocol {
    func getProvinces() async throws -> [ProvinceDTO]
    func getDistricts(provinceId: Int) async throws -> [DistrictDTO]
}
