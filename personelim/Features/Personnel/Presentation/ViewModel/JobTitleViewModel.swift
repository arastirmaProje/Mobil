import Foundation

@MainActor
class JobTitleViewModel: ObservableObject {

    @Published var jobTitles: [JobTitleDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: JobTitleRepositoryProtocol

    init(
        repository: JobTitleRepositoryProtocol =
            JobTitleRepositoryImpl(network: NetworkManager.shared)
    ) {
        self.repository = repository
    }

    func fetchJobTitlesByDepartment(
        departmentId: String
    ) async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            jobTitles = try await repository
                .getTitlesByDepartment(
                    departmentId: departmentId
                )
        } catch {
            errorMessage = ConstantStrings.jobTitlesFetchError

            print(
                "\(ConstantStrings.jobTitlesFetchError): \(error)"
            )
        }
    }
}
