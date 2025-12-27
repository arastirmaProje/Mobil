//
//  AddEmployeeView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import SwiftUI

@MainActor
final class AddEmployeeViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let sendUseCase: SendInvitationUseCaseProtocol

    init(sendUseCase: SendInvitationUseCaseProtocol) {
        self.sendUseCase = sendUseCase
    }

    func send(businessId: String) async {
        errorMessage = nil
        successMessage = nil

        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !e.isEmpty, e.contains("@") else {
            errorMessage = "Geçerli bir email gir."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let res = try await sendUseCase.execute(businessId: businessId, email: e, message: nil)
            successMessage = res.message
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
