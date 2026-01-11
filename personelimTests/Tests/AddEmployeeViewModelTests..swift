//
//  AddEmployeeViewModelTests.swift
//  personelimTests
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

@MainActor
final class AddEmployeeViewModelTests: XCTestCase {
    
    private var useCase: MockSendInvitationUseCase!
    private var vm: AddEmployeeViewModel!
    
    override func setUp() {
        super.setUp()
        useCase = MockSendInvitationUseCase()
        vm = AddEmployeeViewModel(sendUseCase: useCase)
    }
    
    override func tearDown() {
        vm = nil
        useCase = nil
        super.tearDown()
    }
    
    // MARK: - Invalid Email
    
    func test_send_invalidEmail_setsError() async {
        vm.email = "invalid-email"
        
        await vm.send(businessId: "biz_1")
        
        XCTAssertEqual(vm.errorMessage, "Geçerli bir email gir.")
        XCTAssertNil(vm.successMessage)
        XCTAssertFalse(vm.isLoading)
    }
    
    // MARK: - Success
    
    func test_send_success_setsSuccessMessage() async {
        vm.email = "test@mail.com"
        
        useCase.result = .success(
            SendInvitationResponseDTO(
                success: true,
                message: "Davet gönderildi"
            )
        )
        
        await vm.send(businessId: "biz_123")
        
        XCTAssertEqual(vm.successMessage, "Davet gönderildi")
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }
    
    // MARK: - Failure
    
    func test_send_failure_setsErrorMessage() async {
        vm.email = "test@mail.com"
        
        useCase.result = .failure(
            NSError(
                domain: "test",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Sunucu hatası"]
            )
        )
        
        await vm.send(businessId: "biz_1")
        
        XCTAssertEqual(vm.errorMessage, "Sunucu hatası")
        XCTAssertNil(vm.successMessage)
        XCTAssertFalse(vm.isLoading)
    }
    
    // MARK: - Trimming
    
    func test_send_trimsEmailBeforeSending() async {
        vm.email = "  test@mail.com  "
        
        useCase.result = .success(
            SendInvitationResponseDTO(
                success: true,
                message: "OK"
            )
        )
        
        await vm.send(businessId: "biz_1")
        
        XCTAssertEqual(useCase.receivedEmail, "test@mail.com")
    }
}
