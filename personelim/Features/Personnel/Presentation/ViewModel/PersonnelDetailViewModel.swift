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

        defer {
            isLoading = false
        }

        do {
            member = try await getMemberUseCase.execute(
                memberId: memberId
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.memberDetailFail
            )
        }
    }

    func loadReports(
        businessId: String,
        employeeUserId: String
    ) async {
        reportsError = nil
        isReportsLoading = true

        defer {
            isReportsLoading = false
        }

        do {
            reports = try await getReportsUseCase.execute(
                businessId: businessId,
                employeeUserId: employeeUserId
            )
        } catch {
            reportsError = userMessage(
                from: error,
                fallback: ConstantStrings.reportsLoadFailed
            )
        }
    }

    private func userMessage(
        from error: Error,
        fallback: String
    ) -> String {
        if case let RepositoryError.api(message) = error {
            return message
        }

        return fallback
    }
}
