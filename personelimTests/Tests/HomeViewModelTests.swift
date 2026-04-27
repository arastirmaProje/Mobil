//
//  HomeViewModelTests.swift
//  personelimTests
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim
internal import SwiftUI

@MainActor
final class HomeViewModelTests: XCTestCase {

    // MARK: - SUT factory
    private func makeSUT(
        taskRepo: TaskRepositoryProtocol = MockTaskRepo(),
        scheduleRepo: ScheduleRepositoryProtocol = MockScheduleRepo(),
        shiftRepo: ShiftRepositoryProtocol = MockShiftRepo(),
        businessRepo: BusinessRepositoryProtocol = MockBusinessRepo()
    ) -> HomeViewModel {
        HomeViewModel(
            taskRepo: taskRepo,
            scheduleRepo: scheduleRepo,
            shiftRepo: shiftRepo,
            businessRepo: businessRepo
        )
    }

    // MARK: - loadActiveTasks

    func test_loadActiveTasks_filtersOnlyBeklemede() async {
        let tasks: [TaskEntity] = [
            .test(id: "1", status: "Beklemede"),
            .test(id: "2", status: "Tamamlandı"),
            .test(id: "3", status: "Beklemede")
        ]

        let taskRepo = MockTaskRepo(result: .success(tasks))
        let sut = makeSUT(taskRepo: taskRepo)

        await sut.loadActiveTasks(businessId: "business-id")

        XCTAssertEqual(sut.activeTasks.map(\.id), ["1", "3"])
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadActiveTasks_onError_keepsListEmpty() async {
        let taskRepo = MockTaskRepo(result: .failure(TestError.any))
        let sut = makeSUT(taskRepo: taskRepo)

        await sut.loadActiveTasks(businessId: "business-id")

        XCTAssertTrue(sut.activeTasks.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - openDayDetail

    func test_openDayDetail_setsSelectedDetail() {
        let sut = makeSUT()

        let day = Date.make(year: 2026, month: 1, day: 15)
        let key = day.dayKey()

        sut.currentMonthSummaries = [
            ShiftDaySummary(id: "",
                            date: day,
                            dayNumber: 15,
                            dayKey: key,
                            totalSeconds: 10,
                            totalHoursText: "8s",
                            shifts: [ShiftRowUI(timeRangeText: "", durationText: "")],
                            style: ShiftDayStyle(bgColor: .blue, textColor: .black))
        ]

        sut.openDayDetail(day: day)

        XCTAssertEqual(sut.selectedDayDetail?.id, key)
        XCTAssertEqual(sut.selectedDayDetail?.shifts.count, 1)
    }
}
