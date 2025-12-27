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

    private let taskRepo: TaskRepositoryProtocol
    private let businessRepo: BusinessRepositoryProtocol
    let shiftRepo: ShiftRepositoryProtocol

    init(
        taskRepo: TaskRepositoryProtocol = TaskRepositoryImpl(network: NetworkManager()),
        shiftRepo: ShiftRepositoryProtocol = ShiftRepositoryImpl(network: NetworkManager()),
        businessRepo: BusinessRepositoryProtocol = BusinessRepositoryImpl(networkManager: NetworkManager())
    ) {
        self.taskRepo = taskRepo
        self.businessRepo = businessRepo
        self.shiftRepo = shiftRepo
    }

    func loadActiveTasks() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let tasks = try await taskRepo.getMyTasks()
            activeTasks = tasks.filter { $0.status == "Beklemede" }
        } catch {
            print("❌ Home task load error:", error)
        }
    }

    // MARK: - Load month (✅ getMyShifts ile)
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
            print("❌ Home shifts load error:", error)
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
            print("🏢 Office options:", officeOptions.map { $0.title })

        } catch {
            print("❌ Home business load error:", error)
            officeOptions = []
        }
    }
}
