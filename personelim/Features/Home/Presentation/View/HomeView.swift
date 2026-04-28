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

                await vm.loadActiveTasks(businessId: bid)
                await vm.loadOfficeOptions(selectedBusinessId: bid)
                await vm.loadMonthlyShifts(businessId: bid, month: Date())
            }
            .task(id: appState.activitiesChangeToken) {
                guard let bid = appState.businessId else { return }
                await vm.loadActiveTasks(businessId: bid)
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
            .sheet(isPresented: $vm.showDetailSheet) {
                activityDetailSheet
            }
        }
    }
}

// MARK: - Sections
private extension HomeView {

    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ConstantStrings.welcome)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)

                Text(appState.displayName)
                    .font(.system(size: 24, weight: .bold))
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
                        Text(ConstantStrings.shiftHours)
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
                            shiftVM.errorMessage = ConstantStrings.businessIdNotFound
                        }
                    } label: {
                        Text(ConstantStrings.endDay)
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
        if !shiftVM.isRunning { return ConstantStrings.start }
        if shiftVM.isPaused { return ConstantStrings.resume }
        return ConstantStrings.pause
    }

    var activeDayTableSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(ConstantStrings.activeDayTable)
                .font(.system(size: 24, weight: .bold))
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
                Text(ConstantStrings.seeDetails)
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
        VStack(alignment: .leading, spacing: 20) {
            
            Text(ConstantStrings.calendarTitle)
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal)

            HStack(alignment: .top, spacing: 0) {
                ForEach(vm.currentWeekDays, id: \.self) { day in
                    TaskCalendarDayCell(
                        date: day,
                        activities: vm.getActivitiesForDay(day),
                        isSelected: Calendar.current.isDateInToday(day)
                    )
                    .onTapGesture {
                        vm.selectDay(day)
                    }
                    if day != vm.currentWeekDays.last {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 1, height: 100)
                            .padding(.top, 5)
                    }
                }
            }
            .padding(.vertical, 10)
            .background(Color(.systemBackground))

            Button {
                showTaskList = true
            } label: {
                Text(ConstantStrings.allActivities)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(.systemGray5))
                    .cornerRadius(16)
            }
            .padding(.horizontal)
        }
    }

    var activityDetailSheet: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(ConstantStrings.dailyActivitiesTitle)
                    .font(.title2.bold())
                Spacer()
                Button { vm.showDetailSheet = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
            }
            .padding(.top)

            if vm.selectedDateTasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text(ConstantStrings.noActivityFound)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(vm.selectedDateTasks) { task in
                            HStack(spacing: 15) {
                                Rectangle()
                                    .fill(task.activityType.color)
                                    .frame(width: 5)
                                    .cornerRadius(2)

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(task.activityType.rawValue)
                                            .font(.caption2.bold())
                                            .textCase(.uppercase)
                                            .foregroundColor(task.activityType.color)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(task.activityType.color.opacity(0.12))
                                            .cornerRadius(4)
                                        
                                        Text(task.title)
                                            .font(.headline)
                                    }
                                    
                                    if let desc = task.description {
                                        Text(desc)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                
                                Spacer()
                    
                                Text(task.status)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
