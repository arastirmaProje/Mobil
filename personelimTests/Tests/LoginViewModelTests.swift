//
//  LoginViewModelTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

@MainActor
final class LoginViewModelTests: XCTestCase {

    private var viewModel: LoginViewModel!
    private var mockUseCase: MockLoginUseCase!
    private var mockAppState: MockAppState!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockUseCase = MockLoginUseCase()
        viewModel = LoginViewModel(loginUseCase: mockUseCase)
        mockAppState = MockAppState()
    }

    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        mockAppState = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_login_success() async {
        // Given
        viewModel.email = "test@mail.com"
        viewModel.password = "123456"

        mockUseCase.result = .success(
            AuthUserEntity(
                userId: "1",
                email: "test@mail.com",
                fullName: "Test User",
                token: "token123",
                expiresAt: "2026-01-01",
                role: .default
            )
        )

        // When
        await viewModel.login(appState: mockAppState)

        // Then
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(mockAppState.didApplyLogin)
    }

    func test_login_failure_setsErrorMessage() async {
        // Given
        viewModel.email = "test@mail.com"
        viewModel.password = "123456"

        mockUseCase.result = .failure(
            NSError(
                domain: "login",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Giriş başarısız"]
            )
        )

        // When
        await viewModel.login(appState: mockAppState)

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Giriş başarısız")
        XCTAssertFalse(mockAppState.didApplyLogin)
    }

    func test_login_emptyEmailOrPassword_setsValidationError() async {
        // Given
        viewModel.email = ""
        viewModel.password = ""

        // When
        await viewModel.login(appState: mockAppState)

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Email ve şifre zorunludur.")
        XCTAssertFalse(mockAppState.didApplyLogin)
    }
}
