//
//  ShiftCalendarMapperTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

final class ShiftCalendarMapperTests: XCTestCase {

    // MARK: - Helpers

    private func makeShift(
        start: Date,
        end: Date,
        businessId: String? = nil ) -> ShiftDTO {
        ShiftDTO(
            id: UUID().uuidString,
            businessId: businessId,
            startTime: start.isoString(),
            endTime: end.isoString()
        )
    }

    // MARK: - makeMonthSummaries

    func test_makeMonthSummaries_noShifts_returnsDaysForWholeMonth() {
        // Given
        let month = Date.make(year: 2026, month: 1, day: 10)

        // When
        let summaries = ShiftCalendarMapper.makeMonthSummaries(
            month: month,
            shifts: []
        )

        // Then
        XCTAssertEqual(summaries.count, 31)
        XCTAssertTrue(summaries.allSatisfy { $0.totalSeconds == 0 })
        XCTAssertTrue(summaries.allSatisfy { $0.shifts.isEmpty })
    }

    func test_makeMonthSummaries_singleShift_calculatesDurationCorrectly() {
        // Given
        let day = Date.make(year: 2026, month: 1, day: 15)
        let start = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: day)!
        let end = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: day)!

        let shift = makeShift(start: start, end: end)

        // When
        let summaries = ShiftCalendarMapper.makeMonthSummaries(
            month: day,
            shifts: [shift]
        )

        let summary = summaries.first { $0.dayKey == day.dayKey() }

        // Then
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.totalSeconds, 8 * 3600)
        XCTAssertEqual(summary?.totalHoursText, "8s 0dk")
        XCTAssertEqual(summary?.shifts.count, 1)
        XCTAssertEqual(summary?.shifts.first?.timeRangeText, "09:00 - 17:00")
    }

    func test_makeMonthSummaries_multipleShifts_sameDay_accumulatesSeconds() {
        // Given
        let day = Date.make(year: 2026, month: 1, day: 20)

        let s1 = makeShift(
            start: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: day)!,
            end: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: day)!
        )

        let s2 = makeShift(
            start: Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: day)!,
            end: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: day)!
        )

        // When
        let summaries = ShiftCalendarMapper.makeMonthSummaries(
            month: day,
            shifts: [s1, s2]
        )

        let summary = summaries.first { $0.dayKey == day.dayKey() }

        // Then
        XCTAssertEqual(summary?.totalSeconds, 7 * 3600)
        XCTAssertEqual(summary?.shifts.count, 2)
    }

    func test_makeMonthSummaries_invalidShift_isIgnored() {
        // Given
        let day = Date.make(year: 2026, month: 1, day: 5)

        let invalidShift = ShiftDTO(
            id: "x",
            businessId: nil,
            startTime: day.isoString(),
            endTime: Calendar.current
                .date(byAdding: .hour, value: -1, to: day)!
                .isoString()
        )

        // When
        let summaries = ShiftCalendarMapper.makeMonthSummaries(
            month: day,
            shifts: [invalidShift]
        )

        let summary = summaries.first { $0.dayKey == day.dayKey() }

        // Then
        XCTAssertEqual(summary?.totalSeconds, 0)
        XCTAssertTrue(summary?.shifts.isEmpty ?? false)
    }

    // MARK: - formatDuration

    func test_formatDuration_zeroSeconds() {
        XCTAssertEqual(ShiftCalendarMapper.formatDuration(seconds: 0), "0s")
    }

    func test_formatDuration_minutesOnly() {
        XCTAssertEqual(ShiftCalendarMapper.formatDuration(seconds: 30 * 60), "30dk")
    }

    func test_formatDuration_hoursAndMinutes() {
        XCTAssertEqual(
            ShiftCalendarMapper.formatDuration(seconds: 3 * 3600 + 15 * 60),
            "3s 15dk"
        )
    }

    // MARK: - Date helpers

    func test_dayKey_format() {
        let d = Date.make(year: 2026, month: 1, day: 9)
        XCTAssertEqual(d.dayKey(), "2026-01-09")
    }

    func test_monthKey_format() {
        let d = Date.make(year: 2026, month: 11, day: 1)
        XCTAssertEqual(d.monthKey(), "2026-11")
    }

    func test_daysInMonth_count() {
        let feb2024 = Date.make(year: 2024, month: 2, day: 1)
        XCTAssertEqual(feb2024.daysInMonth().count, 29) // leap year
    }
}
