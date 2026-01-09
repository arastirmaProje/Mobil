//
//  HomeView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 2.12.2025.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var appState: AppState

    @StateObject private var vm = HomeViewModel()
    @StateObject private var shiftVM = ShiftTimerViewModel()

    @State private var showTaskList = false
    @State private var showAllTables = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    headerSection

                    shiftSection

                    activeDayTableSection

                    activeTasksSection

                    Spacer(minLength: 12)
                }
                .padding(.bottom, 24)
            }
            .task(id: appState.businessId) {
                guard let bid = appState.businessId else { return }

                await vm.loadActiveTasks()
                await vm.loadOfficeOptions(selectedBusinessId: bid)
                await vm.loadMonthlyShifts(businessId: bid, month: Date())
            }

            .navigationDestination(isPresented: $showTaskList) {
                TasksListView()
            }
            .navigationDestination(isPresented: $showAllTables) {
                AllTablesView(
                    businessId: appState.businessId,
                    repo: vm.shiftRepo
                )
            }
            .sheet(isPresented: $shiftVM.showLocationPicker) {
                ShiftLocationPickerSheet(officeOptions: vm.officeOptions) { picked in
                    shiftVM.confirmStart(option: picked)
                }
            }
            .sheet(item: $vm.selectedDayDetail) { detail in
                ShiftDayDetailSheet(detail: detail)
            }
        }
    }
}

// MARK: - Sections
private extension HomeView {

    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hoş geldin")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)

                Text(appState.displayName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }

    var shiftSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            VStack(spacing: 14) {

                HStack(alignment: .top) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mesai saatleri")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.primary)

                        Text(shiftVM.elapsedText)
                            .font(.system(size: 36, weight: .bold))
                            .monospacedDigit()
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Button {
                        if let bid = appState.businessId {
                            shiftVM.endDay(businessId: bid)
                            Task {
                                await vm.loadMonthlyShifts(businessId: bid, month: Date())
                            }
                        } else {
                            shiftVM.errorMessage = "BusinessId bulunamadı."
                        }
                    } label: {
                        Text("Günü sonlandır")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.22))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!shiftVM.isRunning)
                    .opacity(!shiftVM.isRunning ? 0.55 : 1)
                }

                Button {
                    if !shiftVM.isRunning {
                        shiftVM.openStartSheet()
                    } else if shiftVM.isPaused {
                        shiftVM.resume()
                    } else {
                        shiftVM.pause()
                    }
                } label: {
                    Text(primaryTimerButtonTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .padding(.bottom, 6)

            if let err = shiftVM.errorMessage, !err.isEmpty {
                Text(err)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
        .padding(.top, 2)
    }

    var primaryTimerButtonTitle: String {
        if !shiftVM.isRunning { return "Başlat" }
        if shiftVM.isPaused { return "Devam et" }
        return "Duraklat"
    }

    var activeDayTableSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Aktif gün tablosu")
                .font(.headline)
                .padding(.horizontal)

            ShiftMonthGridView(
                month: vm.currentMonth,
                summaries: vm.currentMonthSummaries,
                onTapDay: { day in
                    vm.openDayDetail(day: day)
                }
            )
            .padding(.horizontal)

            Button {
                showAllTables = true
            } label: {
                Text("Detayları gör")
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
