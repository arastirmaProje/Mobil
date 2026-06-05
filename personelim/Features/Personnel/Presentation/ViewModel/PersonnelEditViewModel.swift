import SwiftUI

@MainActor
final class PersonnelEditViewModel: ObservableObject {

    @Published var position: String = ""
    @Published var salaryText: String = ""

    @Published var jobTitles: [JobTitleDTO] = []
    @Published var selectedPositionId: Int = 0

    @Published var isLoading = false
    @Published var isPositionsLoading = false
    @Published var errorMessage: String?

    @Published var updatedMember: BusinessMemberDTO?
    @Published var didUpdate: Bool = false
    @Published var didDelete: Bool = false

    private let memberRepo: BusinessMemberRepositoryProtocol
    private let updateUseCase: UpdateBusinessMemberUseCaseProtocol
    private let deleteUseCase: DeleteBusinessMemberUseCaseProtocol

    init(
        memberRepo: BusinessMemberRepositoryProtocol,
        updateUseCase: UpdateBusinessMemberUseCaseProtocol,
        deleteUseCase: DeleteBusinessMemberUseCaseProtocol
    ) {
        self.memberRepo = memberRepo
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
    }

    // MARK: - Prefill

    func prefill(from member: BusinessMemberDTO) {
        selectedPositionId = member.positionId ?? 0
        position = member.positionName ?? ""
        salaryText = member.salary.map { String(Int($0)) } ?? ""
    }

    // MARK: - Load Job Titles

    func loadJobTitlesForEdit(
        businessId: String,
        departmentId: String?
    ) async {
        isPositionsLoading = true
        errorMessage = nil

        defer {
            isPositionsLoading = false
        }

        do {
            if let departmentId,
               !departmentId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                await loadJobTitlesFromSingleDepartment(departmentId: departmentId)

            } else {

                try await loadJobTitlesFromAllDepartments(businessId: businessId)
            }

            syncSelectedPositionNameIfNeeded()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadJobTitlesFromSingleDepartment(departmentId: String) async {
        let jobTitleVM = JobTitleViewModel()

        await jobTitleVM.fetchJobTitlesByDepartment(
            departmentId: departmentId
        )

        jobTitles = uniqueJobTitles(jobTitleVM.jobTitles)
    }

    private func loadJobTitlesFromAllDepartments(businessId: String) async throws {
        let departmentRepo = DepartmentRepositoryImpl(network: NetworkManager())

        let departments = try await departmentRepo.fetchDepartments(
            businessId: businessId
        )

        var allTitles: [JobTitleDTO] = []

        for department in departments {
            let jobTitleVM = JobTitleViewModel()

            await jobTitleVM.fetchJobTitlesByDepartment(
                departmentId: department.id
            )

            allTitles.append(contentsOf: jobTitleVM.jobTitles)
        }

        jobTitles = uniqueJobTitles(allTitles)
    }

    private func uniqueJobTitles(_ titles: [JobTitleDTO]) -> [JobTitleDTO] {
        let grouped = Dictionary(grouping: titles, by: { $0.id })

        return grouped
            .compactMap { $0.value.first }
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
    }

    private func syncSelectedPositionNameIfNeeded() {
        if selectedPositionId != 0 {
            if let selected = jobTitles.first(where: { $0.id == selectedPositionId }) {
                position = selected.name
            }

            return
        }

        if let current = jobTitles.first(where: { $0.name == position }) {
            selectedPositionId = current.id
            position = current.name
            return
        }

        if selectedPositionId == 0,
           position.isEmpty,
           let first = jobTitles.first {
            selectedPositionId = first.id
            position = first.name
        }
    }

    // MARK: - Save

    func save(memberId: String, original: BusinessMemberDTO) async {
        errorMessage = nil
        didUpdate = false
        isLoading = true

        defer {
            isLoading = false
        }

        let salaryValue: Double? = {
            let text = salaryText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }

            return Double(
                text.replacingOccurrences(of: ",", with: ".")
            )
        }()

        guard selectedPositionId != 0 else {
            errorMessage = "Lütfen bir ünvan seç."
            return
        }

        let body = UpdateBusinessMemberRequestDTO(
            role: original.role.apiIntValue,
            positionId: selectedPositionId,
            salary: salaryValue,
            tcIdentityNumber: original.tcIdentityNumber
        )

        do {
            try await updateUseCase.execute(
                memberId: memberId,
                body: body
            )

            updatedMember = original
            didUpdate = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func delete(memberId: String) async {
        errorMessage = nil
        didDelete = false
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            try await deleteUseCase.execute(
                memberId: memberId
            )

            didDelete = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
