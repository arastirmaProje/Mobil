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

    func runBulkQuery(businessId: String, start: Date, end: Date) async -> Bool {
        bulkError = nil
        isBulkLoading = true
        defer { isBulkLoading = false }

        do {
            let items = try await bulkUseCase.execute(businessId: businessId, start: start, end: end)

            var dict: [String: Double] = [:]
            for it in items {
                guard let score = it.score else { continue }

                for key in scoreLookupKeys(for: it) {
                    dict[key] = score
                }
            }

            self.bulkScoresByUserId = dict
            return true

        } catch {
            bulkError = error.localizedDescription
            return false
        }
    }

    func scoreText(for member: BusinessMemberDTO) -> String? {
        let score = scoreLookupKeys(for: member).compactMap { bulkScoresByUserId[$0] }.first
        guard let s = score else { return nil }
        return String(format: "%.0f", s)
    }

    private func scoreLookupKeys(for item: PerformanceBulkScoreItemDTO) -> [String] {
        [
            item.employeeUserId,
            item.calisanId,
            item.name.map { "name:\($0)" }
        ]
        .compactMap { normalizedScoreKey($0) }
    }

    private func scoreLookupKeys(for member: BusinessMemberDTO) -> [String] {
        [
            member.userId,
            member.id,
            "name:\(member.fullName)"
        ]
        .compactMap { normalizedScoreKey($0) }
    }

    private func normalizedScoreKey(_ value: String?) -> String? {
        guard let value else { return nil }

        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return normalized.isEmpty ? nil : normalized
    }
}
