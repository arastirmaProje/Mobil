import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var appState: AppState

    @StateObject private var vm = HomeViewModel()
    @StateObject private var shiftVM = ShiftTimerViewModel()

    @State private var showTaskList = false
    @State private var showAllTables = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerSection

                        shiftSection

                        activeDayTableSection

                        activeTasksSection

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
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
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.welcome)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                Text(appState.displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer()

          
        }
        .padding(.horizontal, 18)
    }

    var shiftSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(
                title: ConstantStrings.shiftHours,
                subtitle: shiftVM.isRunning ? "Çalışma süren aktif" : "Mesai başlatılmadı"
            )

            VStack(spacing: 16) {

                Text(shiftVM.elapsedText)
                    .font(.system(size: 46, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                HStack(spacing: 10) {
                    Button {
                        if !shiftVM.isRunning {
                            shiftVM.openStartSheet()
                        } else if shiftVM.isPaused {
                            shiftVM.resume()
                        } else {
                            shiftVM.pause()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: primaryTimerButtonIcon)

                            Text(primaryTimerButtonTitle)
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(primaryTimerButtonColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        if let bid = appState.businessId {
                            shiftVM.endDay(businessId: bid)

                            Task {
                                await vm.loadMonthlyShifts(
                                    businessId: bid,
                                    month: Date()
                                )
                            }
                        } else {
                            shiftVM.errorMessage = ConstantStrings.businessIdNotFound
                        }
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.red)
                            .frame(width: 52, height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.red.opacity(0.10))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!shiftVM.isRunning)
                    .opacity(!shiftVM.isRunning ? 0.45 : 1)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )

            if let err = shiftVM.errorMessage, !err.isEmpty {
                errorInline(err)
            }
        }
        .padding(.horizontal, 18)
    }
    var primaryTimerButtonTitle: String {
        if !shiftVM.isRunning { return ConstantStrings.start }
        if shiftVM.isPaused { return ConstantStrings.resume }
        return ConstantStrings.pause
    }

    var primaryTimerButtonIcon: String {
        if !shiftVM.isRunning { return "play.fill" }
        if shiftVM.isPaused { return "play.fill" }
        return "pause.fill"
    }

    var primaryTimerButtonColor: Color {
        if !shiftVM.isRunning { return .blue }
        if shiftVM.isPaused { return .green }
        return .orange
    }

    var activeDayTableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(
                title: ConstantStrings.activeDayTable,
                subtitle: "Aylık mesai takibini görüntüle"
            )

            VStack(spacing: 14) {
                ShiftMonthGridView(
                    month: vm.currentMonth,
                    summaries: vm.currentMonthSummaries,
                    onTapDay: { day in
                        vm.openDayDetail(day: day)
                    }
                )

                Button {
                    showAllTables = true
                } label: {
                    HStack {
                        Text(ConstantStrings.seeDetails)
                            .font(.headline)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 14)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color.blue.opacity(0.10))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(.horizontal, 18)
    }

    var activeTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(
                title: ConstantStrings.calendarTitle,
                subtitle: "Haftalık aktivite görünümü"
            )

            VStack(spacing: 14) {
                weekCalendarView

                Button {
                    showTaskList = true
                } label: {
                    HStack {
                        Text(ConstantStrings.allActivities)
                            .font(.headline)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 14)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color.blue.opacity(0.10))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(.horizontal, 18)
    }

    var weekCalendarView: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(vm.currentWeekDays, id: \.self) { day in
                TaskCalendarDayCell(
                    date: day,
                    activities: vm.getActivitiesForDay(day),
                    isSelected: Calendar.current.isDateInToday(day)
                )
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.selectDay(day)
                }

                if day != vm.currentWeekDays.last {
                    Rectangle()
                        .fill(Color.black.opacity(0.055))
                        .frame(width: 0.7, height: 96)
                        .padding(.top, 6)
                }
            }
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    var activityDetailSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.dailyActivitiesTitle)
                        .font(.title2.bold())

                    Text("\(vm.selectedDateTasks.count) aktivite")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    vm.showDetailSheet = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)

            if vm.selectedDateTasks.isEmpty {
                emptyActivitySheet
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(vm.selectedDateTasks) { task in
                            activitySheetRow(task)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    func activitySheetRow(_ task: TaskEntity) -> some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(task.activityType.color)
                .frame(width: 4)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 7) {
                    Text(task.activityType.rawValue)
                        .font(.caption2.weight(.bold))
                        .textCase(.uppercase)
                        .foregroundStyle(task.activityType.color)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(task.activityType.color.opacity(0.12))
                        )

                    Text(task.title)
                        .font(.headline)
                        .lineLimit(1)
                }

                if let desc = task.description {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Text(task.status)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.06))
                )
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    var emptyActivitySheet: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.blue)

            Text(ConstantStrings.noActivityFound)
                .font(.headline)
                .foregroundStyle(.primary)

            Text("Bu gün için kayıtlı aktivite bulunmuyor.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 40)
    }

    func sectionTitle(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    func errorInline(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.caption)
                .foregroundStyle(.red)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
