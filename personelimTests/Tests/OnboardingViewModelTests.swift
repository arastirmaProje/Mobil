//
//  OnboardingViewModelTests.swift
//  personelimTests
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

@MainActor
final class OnboardingViewModelTests: XCTestCase {

    private var vm: OnboardingViewModel!

    override func setUp() {
        super.setUp()
        vm = OnboardingViewModel()
    }

    override func tearDown() {
        vm = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState() {
        XCTAssertFalse(vm.showLogin)
        XCTAssertFalse(vm.showRegister)
    }

    // MARK: - Login

    func test_loginTapped_setsShowLoginTrue() {
        vm.loginTapped()

        XCTAssertTrue(vm.showLogin)
        XCTAssertFalse(vm.showRegister)
    }

    // MARK: - Register

    func test_createCompanyTapped_setsShowRegisterTrue() {
        vm.createCompanyTapped()

        XCTAssertTrue(vm.showRegister)
        XCTAssertFalse(vm.showLogin)
    }
}
