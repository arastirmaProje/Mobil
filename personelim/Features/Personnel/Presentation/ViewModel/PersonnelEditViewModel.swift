//
//  PersonnelEditViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import SwiftUI

@MainActor
final class PersonnelEditViewModel: ObservableObject {

    @Published var position: String = ""
    @Published var salaryText: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var updatedMember: BusinessMemberDTO?
    @Published var didDelete: Bool = false

    private let updateUseCase: UpdateBusinessMemberUseCaseProtocol
    private let deleteUseCase: DeleteBusinessMemberUseCaseProtocol

    init(
        updateUseCase: UpdateBusinessMemberUseCaseProtocol,
        deleteUseCase: DeleteBusinessMemberUseCaseProtocol
    ) {
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
    }

    func prefill(from member: BusinessMemberDTO) {
        position = member.position ?? ""
        salaryText = member.salary.map { String(Int($0)) } ?? ""
    }

    func save(memberId: String, original: BusinessMemberDTO) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let salaryValue: Double? = {
            let t = salaryText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { return nil }
            return Double(t.replacingOccurrences(of: ",", with: "."))
        }()

        let body = UpdateBusinessMemberRequestDTO(
            role: original.role.apiIntValue,
            position: position.trimmingCharacters(in: .whitespacesAndNewlines),
            salary: salaryValue,
            tcIdentityNumber: original.tcIdentityNumber
        )

        do {
            try await updateUseCase.execute(memberId: memberId, body: body)
            updatedMember = original

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(memberId: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await deleteUseCase.execute(memberId: memberId)
            didDelete = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
