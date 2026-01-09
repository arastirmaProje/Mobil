//
//  TasksListView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

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

                if !vm.isLoading &&
                    vm.activeTasks.isEmpty &&
                    vm.pastTasks.isEmpty {
                    emptyState
                }

                if !vm.activeTasks.isEmpty {
                    section(
                        title: "Aktif Görevler",
                        tasks: vm.activeTasks
                    )
                }

                if !vm.pastTasks.isEmpty {
                    section(
                        title: "Geçmiş Görevler",
                        tasks: vm.pastTasks
                    )
                }
            }
            .padding(.top)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                showCreateTask = true
            } label: {
                Text("Yeni görev oluştur")
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
        .task {
            await vm.loadIfNeeded()
        }
        .navigationDestination(isPresented: $showCreateTask) {
            CreateTaskView()
                .environmentObject(appState)
                .onDisappear {
                    Task {
                        await vm.refresh()
                    }
                }

        }
    }

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

    private var emptyState: some View {
        VStack(spacing: 12) {

            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("Henüz görev yok")
                .font(.headline)

            Text("Sana atanmış veya tamamladığın bir görev bulunmuyor.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
