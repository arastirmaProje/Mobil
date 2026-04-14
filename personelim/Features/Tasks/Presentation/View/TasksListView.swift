import SwiftUI

struct TasksListView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = TasksListViewModel()
    @State private var showCreateTask = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                }

                if !vm.isLoading && vm.activeTasks.isEmpty && vm.pastTasks.isEmpty {
                    emptyState
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
            .padding(.top)
        }

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
            await vm.loadIfNeeded()
        }

        // MARK: - NAVIGATION FIX
        .navigationDestination(isPresented: $showCreateTask) {
            CreateTaskView()
                .environmentObject(appState)
        }

        .onChange(of: showCreateTask) { isShown in
            if isShown == false {
                Task {
                    await vm.refresh()
                }
            }
        }
    }

    // MARK: - Section

    private func section(
        title: String,
        tasks: [TaskEntity]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

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
                .padding(.horizontal)
            }
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
