//
//  SignupViewModelTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

@MainActor
final class SignupViewModelTests: XCTestCase {

    private var viewModel: SignupViewModel!
    private var mockUseCase: MockRegisterUserUseCase!

    override func setUp() {
        super.setUp()
        mockUseCase = MockRegisterUserUseCase()
        viewModel = SignupViewModel(registerUseCase: mockUseCase)
    }

    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        super.tearDown()
    }

    // MARK: - Validation Tests

    func test_register_emptyFields_showsError() async {
        // Given
        viewModel.firstName = ""
        viewModel.lastName = ""
        viewModel.email = ""
        viewModel.password = ""

        // When
        await viewModel.register()

        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Tüm alanlar gereklidir.")
        XCTAssertFalse(viewModel.goToCreateCompany)
        XCTAssertNil(viewModel.createdUser)
    }

    func test_register_invalidEmail_showsError() async {
        // Given
        viewModel.firstName = "Test"
        viewModel.lastName = "User"
        viewModel.email = "invalidmail"
        viewModel.password = "123456"

        // When
        await viewModel.register()

        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Geçerli bir email giriniz.")
        XCTAssertFalse(viewModel.goToCreateCompany)
    }

    func test_register_shortPassword_showsError() async {
        // Given
        viewModel.firstName = "Test"
        viewModel.lastName = "User"
        viewModel.email = "test@mail.com"
        viewModel.password = "123"

        // When
        await viewModel.register()

        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Şifre en az 6 karakter olmalıdır.")
        XCTAssertFalse(viewModel.goToCreateCompany)
    }

    // MARK: - Success

    func test_register_success_setsUserAndNavigates() async {
        // Given
        viewModel.firstName = "Test"
        viewModel.lastName = "User"
        viewModel.email = "test@mail.com"
        viewModel.password = "123456"

        let authUser = AuthUserEntity(
            userId: "1",
            email: "test@mail.com",
            fullName: "Test User",
            token: "token123",
            expiresAt: "2026-01-01",
            role: .owner
        )

        mockUseCase.result = .success(authUser)

        // When
        await viewModel.register()

        // Then
        XCTAssertFalse(viewModel.showError)
        XCTAssertTrue(viewModel.goToCreateCompany)
        XCTAssertEqual(viewModel.createdUser?.userId, "1")
        XCTAssertEqual(viewModel.createdUser?.role, .owner)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Failure

    func test_register_failure_setsError() async {
        // Given
        viewModel.firstName = "Test"
        viewModel.lastName = "User"
        viewModel.email = "test@mail.com"
        viewModel.password = "123456"

        mockUseCase.result = .failure(
            NSError(
                domain: "register",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Kayıt başarısız"]
            )
        )

        // When
        await viewModel.register()

        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Kayıt başarısız")
        XCTAssertFalse(viewModel.goToCreateCompany)
        XCTAssertNil(viewModel.createdUser)
    }
}
