//
//  RangeCalendarCard.swift
//  personelim
//
//  Created by Tuğberk Acabey on 21.05.2026.
//

import SwiftUI

@available(iOS 17.0, *)
struct RangeCalendarCard: View {

    @Binding var startDate: Date?
    @Binding var endDate: Date?

    @State private var visibleMonth: Date = Date()
    @State private var isSelectingEnd: Bool = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    visibleMonth = Calendar.current.date(byAdding: .month, value: -1, to: visibleMonth) ?? visibleMonth
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }

                Spacer()

                Text(visibleMonth.trMonthTitle())
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Button {
                    visibleMonth = Calendar.current.date(byAdding: .month, value: 1, to: visibleMonth) ?? visibleMonth
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(ConstantStrings.weekdaysShort, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysForVisibleMonth(), id: \.self) { day in
                    RangeCalendarDayCell(
                        day: day,
                        visibleMonth: visibleMonth,
                        start: startDate,
                        end: endDate
                    )
                    .onTapGesture { handleTap(day) }
                }
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .padding(.horizontal)
    }

    private func handleTap(_ day: Date) {
        let selectedDay = day.stripTime()

        if startDate == nil || !isSelectingEnd {
            startDate = selectedDay
            endDate = selectedDay
            isSelectingEnd = true
            return
        }

        guard let currentStart = startDate else { return }

        if selectedDay < currentStart {
            startDate = selectedDay
            endDate = currentStart
        } else if selectedDay > currentStart {
            startDate = currentStart
            endDate = selectedDay
        } else {
            startDate = nil
            endDate = nil
            isSelectingEnd = false
            return
        }

        isSelectingEnd = false
    }

    private func daysForVisibleMonth() -> [Date] {
        let calendar = Calendar.current
        let startOfMonth = visibleMonth.startOfMonth()
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmpty = (weekday + 5) % 7

        var days: [Date] = []
        for index in 0..<leadingEmpty {
            if let day = calendar.date(
                byAdding: .day,
                value: -(leadingEmpty - index),
                to: startOfMonth
            ) {
                days.append(day)
            }
        }

        let range = calendar.range(of: .day, in: .month, for: startOfMonth) ?? 1..<2
        for dayNumber in range {
            if let day = calendar.date(byAdding: .day, value: dayNumber - 1, to: startOfMonth) {
                days.append(day)
            }
        }

        while days.count < 42, let last = days.last,
              let nextDay = calendar.date(byAdding: .day, value: 1, to: last) {
            days.append(nextDay)
        }

        return days
    }
}

@available(iOS 17.0, *)
private struct RangeCalendarDayCell: View {

    let day: Date
    let visibleMonth: Date
    let start: Date?
    let end: Date?

    var body: some View {
        let strippedDay = day.stripTime()
        let isInMonth = day.isSameMonth(as: visibleMonth)
        let isStart = start != nil && strippedDay == start?.stripTime()
        let isEnd = end != nil && strippedDay == end?.stripTime()
        let inRange = isDayInRange(day)
        let isToday = strippedDay == Date().stripTime()

        ZStack {
            if inRange {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.14))
            }

            if isStart || isEnd {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.28))
            }

            if isToday {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary.opacity(0.20), lineWidth: 1)
            }

            Text("\(Calendar.current.component(.day, from: day))")
                .font(.system(size: 13, weight: (isStart || isEnd) ? .semibold : .regular))
                .foregroundColor(isInMonth ? .primary : .secondary.opacity(0.5))
                .frame(maxWidth: .infinity, minHeight: 34)
        }
        .frame(height: 34)
        .contentShape(Rectangle())
    }

    private func isDayInRange(_ day: Date) -> Bool {
        guard let start, let end else { return false }
        return day.isBetweenInclusive(start: start, end: end)
    }
}

extension Date {
    func stripTime() -> Date {
        Calendar.current.startOfDay(for: self)
    }

    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: other)
            && calendar.component(.month, from: self) == calendar.component(.month, from: other)
    }

    func isBetweenInclusive(start: Date, end: Date) -> Bool {
        let day = self.stripTime()
        return day >= min(start, end) && day <= max(start, end)
    }

    func trShortDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: self)
    }

    func trMonthTitle() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: self).capitalized(with: Locale(identifier: "tr_TR"))
    }
}
