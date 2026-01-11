//
//  ForgotPasswordViewModelTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

@MainActor
final class ForgotPasswordViewModelTests: XCTestCase {

    private var mockRepo: MockAuthRepository!
    private var vm: ForgotPasswordViewModel!

    override func setUp() {
        super.setUp()
        mockRepo = MockAuthRepository()
        vm = ForgotPasswordViewModel(authRepository: mockRepo)
    }

    // MARK: - sendCode

    func test_sendCode_success_setsCodeSentTrue() async {
        // Given
        vm.email = "test@mail.com"
        mockRepo.forgotPasswordResult = .success(
            ForgotPasswordResponseEntity(
                email: "test@mail.com",
                expiresAt: "2026-01-11T12:00:00Z",
                expiresInMinutes: 5
            )
        )
        // When
        await vm.sendCode()

        // Then
        XCTAssertTrue(vm.codeSent)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func test_sendCode_emptyEmail_setsError() async {
        // Given
        vm.email = ""

        // When
        await vm.sendCode()

        // Then
        XCTAssertEqual(vm.errorMessage, "Email gereklidir.")
        XCTAssertFalse(vm.codeSent)
    }

    // MARK: - verifyCode

    func test_verifyCode_invalidLength_setsError() async {
        // Given
        vm.code = "123"

        // When
        await vm.verifyCode()

        // Then
        XCTAssertEqual(vm.errorMessage, "Kod 6 haneli olmalıdır.")
        XCTAssertFalse(vm.showResetPassword)
    }

    func test_verifyCode_success_opensResetPassword() async {
        // Given
        vm.code = "123456"
        mockRepo.verifyResetCodeResult = .success(true)

        // When
        await vm.verifyCode()

        // Then
        XCTAssertTrue(vm.showResetPassword)
        XCTAssertNil(vm.errorMessage)
    }

    func test_verifyCode_failure_setsError() async {
        // Given
        vm.code = "123456"
        mockRepo.verifyResetCodeResult = .success(false)

        // When
        await vm.verifyCode()

        // Then
        XCTAssertEqual(vm.errorMessage, "Kod doğrulanamadı.")
        XCTAssertFalse(vm.showResetPassword)
    }
}
