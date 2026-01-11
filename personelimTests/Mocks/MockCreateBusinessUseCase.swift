//
//  MockCreateBusinessUseCase.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

final class MockCreateBusinessUseCase: CreateBusinessUseCaseProtocol {
    func execute(request: CreateBusinessRequestDTO) async throws {}
}

final class MockVerifyBusinessUseCase: VerifyBusinessUseCaseProtocol {
    var result: Bool = true
    func execute(code: String) async throws -> Bool {
        result
    }
}

final class MockCreateBusinessAndGetIdUseCase: CreateBusinessAndGetIdUseCaseProtocol {
    var returnedId: String = "biz_test"
    func execute(request: CreateBusinessRequestDTO) async throws -> String {
        returnedId
    }
}

final class MockGetProvincesUseCase: GetProvincesUseCaseProtocol {
    var result: [ProvinceDTO] = []
    func execute() async throws -> [ProvinceDTO] {
        result
    }
}

final class MockGetDistrictsUseCase: GetDistrictsUseCaseProtocol {
    var result: [DistrictDTO] = []
    func execute(provinceId: Int) async throws -> [DistrictDTO] {
        result
    }
}
