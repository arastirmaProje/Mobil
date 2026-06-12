import Foundation

@MainActor
class BusinessMemberViewModel: ObservableObject {

    @Published var members: [BusinessMemberDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: BusinessMemberRepositoryProtocol

    init(
        repository: BusinessMemberRepositoryProtocol =
            BusinessMemberRepositoryImpl(network: NetworkManager.shared)
    ) {
        self.repository = repository
    }

    func fetchMembers(businessId: String) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            members = try await repository.getMembers(
                businessId: businessId
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.membersLoadFailed
            )
        }
    }

    func addMember(request: CreateMemberRequestDTO) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await repository.addMember(
                request: request
            )

            await fetchMembers(
                businessId: request.businessId
            )

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.memberAddFailed
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
