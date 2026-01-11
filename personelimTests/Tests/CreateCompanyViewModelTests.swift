//
//  CreateCompanyViewModelTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim
import CoreLocation

@MainActor
final class CreateCompanyViewModelTests: XCTestCase {

    // MARK: - Mocks
    private var createBusinessUseCase: MockCreateBusinessUseCase!
    private var verifyBusinessUseCase: MockVerifyBusinessUseCase!
    private var createBusinessAndGetIdUseCase: MockCreateBusinessAndGetIdUseCase!
    private var getProvincesUseCase: MockGetProvincesUseCase!
    private var getDistrictsUseCase: MockGetDistrictsUseCase!

    private var vm: CreateCompanyViewModel!

    override func setUp() {
        super.setUp()

        createBusinessUseCase = MockCreateBusinessUseCase()
        verifyBusinessUseCase = MockVerifyBusinessUseCase()
        createBusinessAndGetIdUseCase = MockCreateBusinessAndGetIdUseCase()
        getProvincesUseCase = MockGetProvincesUseCase()
        getDistrictsUseCase = MockGetDistrictsUseCase()

        vm = CreateCompanyViewModel(
            createBusinessUseCase: createBusinessUseCase,
            verifyBusinessUseCase: verifyBusinessUseCase,
            createBusinessAndGetIdUseCase: createBusinessAndGetIdUseCase,
            getProvincesUseCase: getProvincesUseCase,
            getDistrictsUseCase: getDistrictsUseCase
        )
    }

    override func tearDown() {
        vm = nil
        super.tearDown()
    }

    // MARK: - Provinces

    func test_loadProvinces_success() async {
        getProvincesUseCase.result = [
            ProvinceDTO(id: 1, name: "İstanbul", districts: []),
            ProvinceDTO(id: 2, name: "Ankara", districts: [])
        ]

        await vm.loadProvinces()

        XCTAssertEqual(vm.provinces.count, 2)
        XCTAssertEqual(vm.provinces.first?.name, "İstanbul")
    }

    // MARK: - Districts

    func test_selectProvince_loadsDistricts() async {
        getDistrictsUseCase.result = [
            DistrictDTO(id: 10, name: "Kadıköy", provinceId: 1),
            DistrictDTO(id: 11, name: "Beşiktaş", provinceId: 1)
        ]

        await vm.selectProvince(1)

        XCTAssertEqual(vm.selectedProvinceId, 1)
        XCTAssertEqual(vm.districts.count, 2)
        XCTAssertEqual(vm.districts.first?.name, "Kadıköy")
    }

    // MARK: - Create Company

    func test_createCompany_invalidForm_setsError() async {
        await vm.createCompany(appState: AppState())

        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.showOTP)
    }

    func test_createCompany_success_setsShowOTP() async {
        vm.companyName = "Test Şirket"
        vm.selectedProvinceId = 1
        vm.selectedDistrictId = 10

        createBusinessAndGetIdUseCase.returnedId = "biz_123"

        await vm.createCompany(appState: AppState())

        XCTAssertTrue(vm.showOTP)
        XCTAssertNil(vm.errorMessage)
    }

    // MARK: - Verify Business

    func test_verifyBusiness_success() async throws {
        verifyBusinessUseCase.result = true

        try await vm.verifyBusiness(code: "123456")
    }

    func test_verifyBusiness_failure_throws() async {
        verifyBusinessUseCase.result = false

        do {
            try await vm.verifyBusiness(code: "000000")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(true)
        }
    }
}
