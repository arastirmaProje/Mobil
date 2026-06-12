import Foundation

@MainActor
final class TasksListViewModel: ObservableObject {

    @Published var activeTasks: [TaskEntity] = []
    @Published var pastTasks: [TaskEntity] = []
    @Published var isLoading = false
    @Published var deletingTaskIds: Set<String> = []
    @Published var errorMessage: String?

    private let getActivitiesUseCase: GetActivitiesUseCase
    private let deleteActivityUseCase: DeleteActivityUseCase
    private var didLoad = false

    init(
        getActivitiesUseCase: GetActivitiesUseCase = GetActivitiesUseCase(
            taskRepository: TaskRepositoryImpl(network: NetworkManager()),
            scheduleRepository: ScheduleRepositoryImpl(network: NetworkManager())
        ),
        deleteActivityUseCase: DeleteActivityUseCase = DeleteActivityUseCase(
            taskRepository: TaskRepositoryImpl(network: NetworkManager()),
            scheduleRepository: ScheduleRepositoryImpl(network: NetworkManager())
        )
    ) {
        self.getActivitiesUseCase = getActivitiesUseCase
        self.deleteActivityUseCase = deleteActivityUseCase
    }

    func loadIfNeeded(businessId: String) async {
        guard !didLoad else { return }
        didLoad = true
        await load(businessId: businessId)
    }

    func refresh(businessId: String) async {
        didLoad = false
        await loadIfNeeded(businessId: businessId)
    }

    private func load(businessId: String) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let tasks = try await getActivitiesUseCase.execute(
                businessId: businessId
            )
            mapTasks(tasks)
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.tasksNoDownload
            )
        }
    }

    private func mapTasks(_ tasks: [TaskEntity]) {
        let now = Date()

        activeTasks = tasks.filter {
            $0.statusEnum == .beklemede &&
            $0.endDate >= now
        }

        pastTasks = tasks.filter {
            $0.statusEnum == .done ||
            $0.statusEnum == .closed ||
            $0.endDate < now
        }
    }

    func delete(_ task: TaskEntity) async -> Bool {
        guard !deletingTaskIds.contains(task.id) else { return false }

        deletingTaskIds.insert(task.id)
        errorMessage = nil

        defer {
            deletingTaskIds.remove(task.id)
        }

        do {
            try await deleteActivityUseCase.execute(
                activityId: task.id,
                activityType: task.activityType
            )

            activeTasks.removeAll { $0.id == task.id }
            pastTasks.removeAll { $0.id == task.id }

            return true

        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.activityDeleteFailed
            )
            return false
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
