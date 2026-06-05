import SwiftUI

struct TasksListView: View {

    @EnvironmentObject private var appState: AppState
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var vm = TasksListViewModel()
    @State private var showCreateTask = false
    @State private var hasLoadedOnce = false
    @State private var selectedTask: TaskEntity?

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            List {
                if vm.isLoading && !hasLoadedOnce {
                    loadingSection
                }

                if !vm.isLoading && vm.activeTasks.isEmpty && vm.pastTasks.isEmpty {
                    emptyState
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(
                            EdgeInsets(
                                top: 40,
                                leading: 16,
                                bottom: 16,
                                trailing: 16
                            )
                        )
                }

                if !vm.activeTasks.isEmpty {
                    section(
                        title: ConstantStrings.activeTasksTitle,
                        subtitle: "\(vm.activeTasks.count) aktif kayıt",
                        tasks: vm.activeTasks
                    )
                }

                if !vm.pastTasks.isEmpty {
                    section(
                        title: ConstantStrings.pastTasksTitle,
                        subtitle: "\(vm.pastTasks.count) geçmiş kayıt",
                        tasks: vm.pastTasks
                    )
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
            .refreshable {
                await refreshTasks()
            }
        }
        .navigationTitle(ConstantStrings.activitiesNavTitle)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            bottomCreateButton
        }
        .task {
            await initialLoad()
        }
        .onAppear {
            Task {
                if hasLoadedOnce {
                    await refreshTasks()
                }
            }
        }
        .onChange(of: appState.activitiesChangeToken) { _ in
            Task {
                await refreshTasks()
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                Task {
                    if hasLoadedOnce {
                        await refreshTasks()
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showCreateTask) {
            CreateTaskView()
                .environmentObject(appState)
        }
        .navigationDestination(
            isPresented: Binding(
                get: {
                    selectedTask != nil
                },
                set: { isPresented in
                    if !isPresented {
                        selectedTask = nil
                    }
                }
            )
        ) {
            if let task = selectedTask {
                TaskDetailView(
                    task: task,
                    currentUserId: appState.userId
                )
            }
        }
        .onChange(of: showCreateTask) { isShown in
            if isShown == false {
                Task {
                    await refreshTasks()
                }
            }
        }
        .alert(
            ConstantStrings.errorTitle,
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { _ in vm.errorMessage = nil }
            )
        ) {
            Button(ConstantStrings.okButton, role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Load / Refresh

    private func initialLoad() async {
        guard let businessId = appState.businessId else { return }

        if !hasLoadedOnce {
            await vm.loadIfNeeded(businessId: businessId)
            hasLoadedOnce = true
        }
    }

    private func refreshTasks() async {
        guard let businessId = appState.businessId else { return }
        await vm.refresh(businessId: businessId)
    }

    // MARK: - Loading

    private var loadingSection: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("Aktiviteler yükleniyor...")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .listRowInsets(
            EdgeInsets(
                top: 16,
                leading: 16,
                bottom: 8,
                trailing: 16
            )
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    // MARK: - Section

    private func section(
        title: String,
        subtitle: String,
        tasks: [TaskEntity]
    ) -> some View {
        Section {
            ForEach(tasks) { task in
                Button {
                    selectedTask = task
                } label: {
                    TaskCardView(
                        task: task,
                        currentUserId: appState.userId
                    )
                }
                .buttonStyle(.plain)
                .listRowInsets(
                    EdgeInsets(
                        top: 6,
                        leading: 16,
                        bottom: 6,
                        trailing: 16
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            let ok = await vm.delete(task)

                            if ok {
                                appState.signalActivitiesChanged()
                                await refreshTasks()
                            }
                        }
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .disabled(vm.deletingTaskIds.contains(task.id))
            }
        } header: {
            sectionHeader(
                title: title,
                subtitle: subtitle
            )
        }
        .headerProminence(.increased)
    }

    private func sectionHeader(
        title: String,
        subtitle: String
    ) -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.primary)
                    .textCase(nil)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(nil)
            }

            Spacer()
        }
        .padding(.top, 14)
        .padding(.bottom, 8)
        .listRowInsets(
            EdgeInsets(
                top: 0,
                leading: 16,
                bottom: 0,
                trailing: 16
            )
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.blue)

            VStack(spacing: 5) {
                Text(ConstantStrings.emptyTasksTitle)
                    .font(.headline)

                Text(ConstantStrings.emptyTasksDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showCreateTask = true
            } label: {
                Label(ConstantStrings.createTaskButton, systemImage: "plus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Bottom Button

    private var bottomCreateButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                showCreateTask = true
            } label: {
                Label(ConstantStrings.createTaskButton, systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }
}
