import SwiftUI

@MainActor
final class PersonnelListViewModel: ObservableObject {

    @Published var query: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isBulkLoading: Bool = false
    @Published var bulkError: String?
    @Published var bulkScoresByUserId: [String: Double] = [:]

    private let bulkUseCase: QueryBulkPerformanceScoresUseCaseProtocol

    init(
        bulkUseCase: QueryBulkPerformanceScoresUseCaseProtocol = QueryBulkPerformanceScoresUseCase(
            repo: PerformanceRepositoryImpl(network: NetworkManager())
        )
    ) {
        self.bulkUseCase = bulkUseCase
    }

    func filtered(_ members: [BusinessMemberDTO]) -> [BusinessMemberDTO] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return members }
        return members.filter {
            $0.fullName.localizedCaseInsensitiveContains(q) ||
            $0.email.localizedCaseInsensitiveContains(q)
        }
    }

    func runBulkQuery(businessId: String, start: Date, end: Date) async {
        bulkError = nil
        isBulkLoading = true
        defer { isBulkLoading = false }

        do {
            let items = try await bulkUseCase.execute(businessId: businessId, start: start, end: end)

            var dict: [String: Double] = [:]
            for it in items {
                if let uid = it.userId?.lowercased(),
                   let sc = it.score {
                    dict[uid] = sc
                }
            }

            self.bulkScoresByUserId = dict

        } catch {
            bulkError = error.localizedDescription
        }
    }

    func scoreText(for member: BusinessMemberDTO) -> String? {
        guard let s = bulkScoresByUserId[member.userId.lowercased()] else { return nil }
        return String(format: "%.0f", s)
    }
}
