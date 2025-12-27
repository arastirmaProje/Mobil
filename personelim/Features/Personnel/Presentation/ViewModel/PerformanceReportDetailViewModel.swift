//
//  PerformanceReportDetailViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

@MainActor
final class PerformanceReportDetailViewModel: ObservableObject {

    @Published var report: PerformanceReportDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let detailUseCase: GetPerformanceReportDetailUseCaseProtocol

    init(detailUseCase: GetPerformanceReportDetailUseCaseProtocol) {
        self.detailUseCase = detailUseCase
    }

    func load(reportId: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            report = try await detailUseCase.execute(reportId: reportId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
