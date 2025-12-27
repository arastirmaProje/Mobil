//
//  PersonnelDetailViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import SwiftUI

@MainActor
final class PersonnelDetailViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var member: BusinessMemberDTO?

    @Published var reports: [PerformanceReportDTO] = []
    @Published var isReportsLoading: Bool = false
    @Published var reportsError: String?

    private let getMemberUseCase: GetBusinessMemberUseCaseProtocol
    private let getReportsUseCase: GetPerformanceReportsUseCaseProtocol

    init(
        getMemberUseCase: GetBusinessMemberUseCaseProtocol,
        getReportsUseCase: GetPerformanceReportsUseCaseProtocol
    ) {
        self.getMemberUseCase = getMemberUseCase
        self.getReportsUseCase = getReportsUseCase
    }

    func load(memberId: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            member = try await getMemberUseCase.execute(memberId: memberId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadReports(businessId: String, employeeUserId: String) async {
        reportsError = nil
        isReportsLoading = true
        defer { isReportsLoading = false }

        do {
            let list = try await getReportsUseCase.execute(businessId: businessId, employeeUserId: employeeUserId)
            self.reports = list
        } catch {
            reportsError = error.localizedDescription
        }
    }
}
