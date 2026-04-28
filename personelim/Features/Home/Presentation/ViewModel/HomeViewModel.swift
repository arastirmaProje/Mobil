//
//  HomeViewModel.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.12.2025.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var activeTasks: [TaskEntity] = []
    @Published var isLoading = false
    @Published var officeOptions: [ShiftStartOption] = []
    @Published var currentMonth: Date = Date()
    @Published var currentMonthSummaries: [ShiftDaySummary] = []
    @Published var selectedDayDetail: ShiftDayDetail?
    @Published var selectedDateTasks: [TaskEntity] = [] 
        @Published var showDetailSheet: Bool = false
    
    private let getActivitiesUseCase: GetActivitiesUseCase
    private let businessRepo: BusinessRepositoryProtocol
    let shiftRepo: ShiftRepositoryProtocol
    
    init(
        taskRepo: TaskRepositoryProtocol = TaskRepositoryImpl(network: NetworkManager()),
        scheduleRepo: ScheduleRepositoryProtocol = ScheduleRepositoryImpl(network: NetworkManager()),
        shiftRepo: ShiftRepositoryProtocol = ShiftRepositoryImpl(network: NetworkManager()),
        businessRepo: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager())
    ) {
        self.getActivitiesUseCase = GetActivitiesUseCase(
            taskRepository: taskRepo,
            scheduleRepository: scheduleRepo
        )
        self.businessRepo = businessRepo
        self.shiftRepo = shiftRepo
    }
    
    func loadActiveTasks(businessId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let tasks = try await getActivitiesUseCase.execute(businessId: businessId)
            let now = Date()
            activeTasks = tasks.filter {
                $0.statusEnum == .beklemede &&
                $0.endDate >= now
            }
        } catch {
            print(" Home task load error:", error)
        }
    }
    
    // MARK: - Load month
    func loadMonthlyShifts(businessId: String, month: Date) async {
        currentMonth = month
        
        do {
            let allShifts = try await shiftRepo.getMyShifts(businessId: businessId)
            
            let range = month.monthDateRange()
            let filtered = allShifts.filter { s in
                guard let start = Date.isoToDate(s.startTime) else { return false }
                return (start >= range.start) && (start < range.end)
            }
            
            self.currentMonthSummaries = ShiftCalendarMapper.makeMonthSummaries(
                month: month,
                shifts: filtered
            )
            
        } catch {
            print("Home shifts load error:", error)
            self.currentMonthSummaries = ShiftCalendarMapper.makeMonthSummaries(
                month: month,
                shifts: []
            )
        }
    }
    
    func openDayDetail(day: Date) {
        let dayKey = day.dayKey()
        let summary = currentMonthSummaries.first(where: { $0.dayKey == dayKey })
        guard let summary else { return }
        
        selectedDayDetail = ShiftDayDetail(
            id: dayKey,
            date: day,
            totalHoursText: summary.totalHoursText,
            shifts: summary.shifts
        )
    }
    
    func loadOfficeOptions(selectedBusinessId: String?) async {
        do {
            let businesses = try await businessRepo.getBusinesses()
            
            let selected: BusinessDTO?
            if let bid = selectedBusinessId {
                selected = businesses.first { $0.id.lowercased() == bid.lowercased() }
            } else {
                selected = businesses.first
            }
            
            guard let b = selected else {
                officeOptions = []
                return
            }
            
            officeOptions = b.toShiftOfficeOptions()
            print("Office options:", officeOptions.map { $0.title })
            
        } catch {
            print("Home business load error:", error)
            officeOptions = []
        }
    }
    
    var currentWeekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        
        let daysToSubtract = (dayOfWeek - calendar.firstWeekday + 7) % 7
        let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
        
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    func getActivitiesForDay(_ date: Date) -> [ActivityType] {
        let dayKey = date.taskDayKey()
        
        let tasksForDay = activeTasks.filter { task in
            return task.startDate.taskDayKey() == dayKey
        }
        
        let uniqueTypes = Set(tasksForDay.map { $0.activityType })
        
        return Array(uniqueTypes).sorted { $0.rawValue < $1.rawValue }
    }
    
    func selectDay(_ day: Date) {
            let dayKey = day.taskDayKey()
            self.selectedDateTasks = activeTasks.filter { $0.startDate.taskDayKey() == dayKey }
            self.showDetailSheet = true
        }
}
