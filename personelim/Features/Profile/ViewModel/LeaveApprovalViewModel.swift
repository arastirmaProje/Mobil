import Foundation

@MainActor
final class LeaveApprovalViewModel: ObservableObject {

    @Published var leaves: [LeaveDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: LeaveRepositoryProtocol
    private var loadTask: Task<Void, Never>?

    init(
        repository: LeaveRepositoryProtocol = LeaveRepositoryImpl(
            network: NetworkManager()
        )
    ) {
        self.repository = repository
    }

    func loadLeaves(
        businessId: String,
        force: Bool = false
    ) async {
        if loadTask != nil && !force {
            await loadTask?.value
            return
        }

        isLoading = true
        errorMessage = nil

        loadTask = Task { @MainActor in
            defer {
                self.isLoading = false
                self.loadTask = nil
            }

            do {
                self.leaves = try await repository.getBusinessLeaves(
                    businessId: businessId
                )
            } catch {
                self.errorMessage = self.userMessage(
                    from: error,
                    fallback: ConstantStrings.leaveRequestsLoadFailed
                )
            }
        }

        await loadTask?.value
    }

    func approveLeave(
        _ leave: LeaveDTO,
        businessId: String
    ) async {
        await updateLeave(
            leave,
            status: 1,
            rejectionReason: nil,
            businessId: businessId
        )
    }

    func rejectLeave(
        _ leave: LeaveDTO,
        reason: String,
        businessId: String
    ) async {
        let trimmedReason = reason.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        await updateLeave(
            leave,
            status: 2,
            rejectionReason: trimmedReason,
            businessId: businessId
        )
    }

    private func updateLeave(
        _ leave: LeaveDTO,
        status: Int,
        rejectionReason: String?,
        businessId: String
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.updateLeaveStatus(
                leaveId: leave.id,
                status: status,
                rejectionReason: rejectionReason
            )

            await loadLeaves(
                businessId: businessId,
                force: true
            )

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.leaveStatusUpdateFailed
            )
            isLoading = false
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
