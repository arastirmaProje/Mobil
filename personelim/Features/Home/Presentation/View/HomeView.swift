//
//  HomeView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 2.12.2025.
//

import SwiftUI

struct HomeView: View {

    @StateObject private var vm = HomeViewModel()
    @State private var showTaskList = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                    activeTasksSection
                }
                .padding(.bottom, 24)
            }
            .task {
                await vm.loadActiveTasks()
            }
            .navigationDestination(isPresented: $showTaskList) {
                TasksListView()
            }
        }
    }
}

private extension HomeView {

    var activeTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Aktif görevler")
                .font(.headline)
                .padding(.horizontal)

            ForEach(vm.activeTasks.prefix(3)) { task in
                TaskCardView(
                    task: task,
                    currentUserId: nil
                )
                .padding(.horizontal)
            }

            if vm.activeTasks.isEmpty && !vm.isLoading {
                Text("Aktif görevin yok 🎉")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            Button {
                showTaskList = true
            } label: {
                Text("Tüm görevleri gör")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(14)
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }
}
