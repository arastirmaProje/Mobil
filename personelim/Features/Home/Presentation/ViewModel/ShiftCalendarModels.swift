//
//  ShiftCalendarModels.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 26.12.2025.
//

import Foundation
import SwiftUI


struct ShiftDayDetail: Identifiable {
    let id: String
    let date: Date
    let totalHoursText: String
    let shifts: [ShiftRowUI]
}

struct ShiftRowUI {
    let timeRangeText: String
    let durationText: String
}


struct ShiftDaySummary: Identifiable {
    let id: String
    let date: Date
    let dayNumber: Int
    let dayKey: String
    let totalSeconds: Int
    let totalHoursText: String
    let shifts: [ShiftRowUI]
    let style: ShiftDayStyle
}

struct ShiftDayStyle {
    let bgColor: Color
    let textColor: Color
}

enum ShiftCalendarMapper {

    static func makeMonthSummaries(month: Date, shifts: [ShiftDTO]) -> [ShiftDaySummary] {
        let days = month.daysInMonth()
        let grouped: [String: [ShiftDTO]] = Dictionary(grouping: shifts) { s in
            let d = Date.isoToDate(s.startTime) ?? Date()
            return d.dayKey()
        }

        return days.map { day in
            let key = day.dayKey()
            let dayShifts = grouped[key] ?? []

            var totalSec = 0
            var rows: [ShiftRowUI] = []

            for s in dayShifts {
                let start = Date.isoToDate(s.startTime)
                let end = Date.isoToDate(s.endTime)

                if let start, let end, end >= start {
                    let sec = Int(end.timeIntervalSince(start))
                    totalSec += sec

                    rows.append(
                        ShiftRowUI(
                            timeRangeText: "\(start.hourMinuteTR()) - \(end.hourMinuteTR())",
                            durationText: formatDuration(seconds: sec)
                        )
                    )
                }
            }

            let style = styleFor(totalSeconds: totalSec)

            return ShiftDaySummary(
                id: key,
                date: day,
                dayNumber: Calendar.current.component(.day, from: day),
                dayKey: key,
                totalSeconds: totalSec,
                totalHoursText: formatDuration(seconds: totalSec),
                shifts: rows,
                style: style
            )
        }
    }

    private static func styleFor(totalSeconds: Int) -> ShiftDayStyle {
        if totalSeconds <= 0 {
            return ShiftDayStyle(bgColor: Color(.systemGray5), textColor: .primary)
        }

        let hours = Double(totalSeconds) / 3600.0
        if hours < 3 {
            return ShiftDayStyle(bgColor: Color.green.opacity(0.28), textColor: .primary)
        } else if hours < 7 {
            return ShiftDayStyle(bgColor: Color.green.opacity(0.55), textColor: .white)
        } else {
            return ShiftDayStyle(bgColor: Color.green.opacity(0.85), textColor: .white)
        }
    }

    static func formatDuration(seconds: Int) -> String {
        guard seconds > 0 else { return "0s" }
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 { return "\(h)s \(m)dk" }
        return "\(m)dk"
    }
}

// MARK: - Date helpers
extension Date {

    func monthDateRange() -> (start: Date, end: Date) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: self)) ?? self
        let end = cal.date(byAdding: .month, value: 1, to: start) ?? start
        return (start, end)
    }

    func daysInMonth() -> [Date] {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: self) ?? 1..<2
        let start = cal.date(from: cal.dateComponents([.year, .month], from: self)) ?? self
        return range.compactMap { day in
            cal.date(byAdding: .day, value: day - 1, to: start)
        }
    }

    func dayKey() -> String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: self)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    func monthKey() -> String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month], from: self)
        return String(format: "%04d-%02d", c.year ?? 0, c.month ?? 0)
    }

    func monthTitleTR() -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "tr_TR")
        fmt.dateFormat = "LLLL"
        let name = fmt.string(from: self)
        return name.prefix(1).uppercased() + name.dropFirst()
    }

    func dayTitleTR() -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "tr_TR")
        fmt.dateFormat = "d MMMM yyyy"
        return fmt.string(from: self)
    }

    func hourMinuteTR() -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "tr_TR")
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: self)
    }

    static func makeRecentMonths(count: Int) -> [Date] {
        let cal = Calendar.current
        return (0..<count).compactMap { i in
            cal.date(byAdding: .month, value: -i, to: Date())
        }.reversed()
    }

    static func isoToDate(_ s: String?) -> Date? {
        guard let s else { return nil }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: s) { return d }
        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        return f2.date(from: s)
    }

    func isoString() -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: self)
    }
}
