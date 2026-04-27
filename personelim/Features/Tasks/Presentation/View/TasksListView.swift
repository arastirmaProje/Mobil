import SwiftUI

struct TasksListView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = TasksListViewModel()
    @State private var showCreateTask = false

    var body: some View {
        List {
            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            if !vm.isLoading && vm.activeTasks.isEmpty && vm.pastTasks.isEmpty {
                emptyState
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            if !vm.activeTasks.isEmpty {
                section(
                    title: ConstantStrings.activeTasksTitle,
                    tasks: vm.activeTasks
                )
            }

            if !vm.pastTasks.isEmpty {
                section(
                    title: ConstantStrings.pastTasksTitle,
                    tasks: vm.pastTasks
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationTitle(ConstantStrings.activitiesNavTitle)

        // MARK: - Bottom Button
        .safeAreaInset(edge: .bottom) {
            Button {
                showCreateTask = true
            } label: {
                Text(ConstantStrings.createTaskButton)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }

        // MARK: - Initial Load
        .task {
            guard let businessId = appState.businessId else { return }
            await vm.loadIfNeeded(businessId: businessId)
        }

        // MARK: - NAVIGATION FIX
        .navigationDestination(isPresented: $showCreateTask) {
            CreateTaskView()
                .environmentObject(appState)
        }

        .onChange(of: showCreateTask) { isShown in
            if isShown == false {
                Task {
                    guard let businessId = appState.businessId else { return }
                    await vm.refresh(businessId: businessId)
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

    // MARK: - Section

    private func section(
        title: String,
        tasks: [TaskEntity]
    ) -> some View {
        Section {
            ForEach(tasks) { task in
                NavigationLink {
                    TaskDetailView(
                        task: task,
                        currentUserId: appState.userId
                    )
                } label: {
                    TaskCardView(
                        task: task,
                        currentUserId: appState.userId
                    )
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            let ok = await vm.delete(task)
                            if ok {
                                appState.signalActivitiesChanged()
                            }
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
                .disabled(vm.deletingTaskIds.contains(task.id))
            }
        } header: {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .textCase(nil)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text(ConstantStrings.emptyTasksTitle)
                .font(.headline)

            Text(ConstantStrings.emptyTasksDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
