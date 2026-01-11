//
//  ResetPasswordViewModelTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

@MainActor
final class ResetPasswordViewModelTests: XCTestCase {

    private var viewModel: ResetPasswordViewModel!
    private var mockUseCase: MockResetPasswordUseCase!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockUseCase = MockResetPasswordUseCase()
        viewModel = ResetPasswordViewModel(
            email: "test@mail.com",
            code: "123456",
            resetPasswordUseCase: mockUseCase
        )
    }

    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_resetPassword_emptyFields_showsError() async {
        // Given
        viewModel.newPassword = ""
        viewModel.confirmPassword = ""

        // When
        await viewModel.resetPassword()

        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Şifre alanları boş olamaz.")
        XCTAssertFalse(viewModel.success)
    }

    func test_resetPassword_passwordsDoNotMatch_showsError() async {
        // Given
        viewModel.newPassword = "123456"
        viewModel.confirmPassword = "654321"

        // When
        await viewModel.resetPassword()

        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Şifreler eşleşmiyor.")
        XCTAssertFalse(viewModel.success)
    }

    func test_resetPassword_success_setsSuccessTrue() async {
        // Given
        viewModel.newPassword = "123456"
        viewModel.confirmPassword = "123456"
        mockUseCase.result = .success(true)

        // When
        await viewModel.resetPassword()

        // Then
        XCTAssertFalse(viewModel.showError)
        XCTAssertTrue(viewModel.success)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_resetPassword_failure_setsErrorMessage() async {
        // Given
        viewModel.newPassword = "123456"
        viewModel.confirmPassword = "123456"
        mockUseCase.result = .failure(
            NSError(
                domain: "reset",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Şifre sıfırlanamadı"]
            )
        )

        // When
        await viewModel.resetPassword()

        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Şifre sıfırlanamadı")
        XCTAssertFalse(viewModel.success)
    }
}
