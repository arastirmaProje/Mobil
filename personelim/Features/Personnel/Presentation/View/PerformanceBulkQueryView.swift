//
//  PerformanceBulkQueryView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 28.12.2025.
//

import SwiftUI

struct PerformanceBulkQueryView: View {

    @Environment(\.dismiss) private var dismiss

    let businessId: String
    let onCompleted: (Date, Date) -> Void

    @ObservedObject private var vm: PersonnelListViewModel

    @State private var visibleMonth: Date = Date()

    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var endDate: Date = Date()

    init(
        businessId: String,
        vm: PersonnelListViewModel,
        onCompleted: @escaping (Date, Date) -> Void
    ) {
        self.businessId = businessId
        self._vm = ObservedObject(wrappedValue: vm)
        self.onCompleted = onCompleted
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    Text(ConstantStrings.bulkQueryTitle)
                        .font(.system(size: 24, weight: .semibold))

                    Text(ConstantStrings.calendarInstruction)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    rangeSummary

                    RangeCalendarView(
                        visibleMonth: $visibleMonth,
                        startDate: $startDate,
                        endDate: $endDate
                    )

                    if let err = vm.bulkError {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.system(size: 13))
                    }

                    Spacer().frame(height: 18)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await vm.runBulkQuery(businessId: businessId, start: startDate, end: endDate)
                            onCompleted(startDate, endDate)
                            dismiss()
                        }
                    } label: {
                        Image(systemName: vm.isBulkLoading ? "hourglass" : "checkmark")
                    }
                    .disabled(vm.isBulkLoading)
                }
            }
        }
        .onAppear {
            visibleMonth = startDate
        }
    }

    private var rangeSummary: some View {
        HStack(spacing: 6) {
            Text("\(ConstantStrings.startDatePrefix)\(startDate.trShortDate())")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            Text("\(ConstantStrings.endDatePrefix)\(endDate.trShortDate())")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.top, 2)
    }
}

// MARK: - RangeCalendarView

private struct RangeCalendarView: View {

    @Binding var visibleMonth: Date
    @Binding var startDate: Date
    @Binding var endDate: Date

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    @State private var isSelectingEnd: Bool = false

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
                .buttonStyle(.plain)

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
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(ConstantStrings.weekdaysShort, id: \.self) { w in
                    Text(w)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysForVisibleMonth(), id: \.self) { day in
                    DayCell(
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
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func handleTap(_ day: Date) {
        let d = day.stripTime()
        let s = startDate.stripTime()

        if !isSelectingEnd {
            startDate = d
            endDate = d
            isSelectingEnd = true
            return
        }

        if d < s {
            startDate = d
            endDate = s
        } else {
            endDate = d
        }

        isSelectingEnd = false
    }

    private func daysForVisibleMonth() -> [Date] {
        let cal = Calendar.current
        let startOfMonth = visibleMonth.startOfMonth()
        let weekday = cal.component(.weekday, from: startOfMonth)
        let leadingEmpty = (weekday + 5) % 7

        var days: [Date] = []
        for i in 0..<leadingEmpty {
            days.append(cal.date(byAdding: .day, value: -(leadingEmpty - i), to: startOfMonth)!)
        }

        let range = cal.range(of: .day, in: .month, for: startOfMonth) ?? 1..<2
        for d in range {
            days.append(cal.date(byAdding: .day, value: d - 1, to: startOfMonth)!)
        }

        while days.count < 42 {
            days.append(cal.date(byAdding: .day, value: 1, to: days.last!)!)
        }

        return days
    }
}



// MARK: - DayCell

private struct DayCell: View {

    let day: Date
    let visibleMonth: Date
    let start: Date
    let end: Date

    var body: some View {
        let isInMonth = day.isSameMonth(as: visibleMonth)
        let isStart = day.stripTime() == start.stripTime()
        let isEnd = day.stripTime() == end.stripTime()
        let inRange = day.isBetweenInclusive(start: start, end: end)
        let isToday = day.stripTime() == Date().stripTime()

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
}

// MARK: - Date helpers

private extension Date {

    func stripTime() -> Date {
        Calendar.current.startOfDay(for: self)
    }

    func startOfMonth() -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: self)
        return cal.date(from: comps) ?? self
    }

    func isSameMonth(as other: Date) -> Bool {
        let cal = Calendar.current
        return cal.component(.year, from: self) == cal.component(.year, from: other)
        && cal.component(.month, from: self) == cal.component(.month, from: other)
    }

    func isBetweenInclusive(start: Date, end: Date) -> Bool {
        let d = self.stripTime()
        let s = start.stripTime()
        let e = end.stripTime()
        return d >= min(s, e) && d <= max(s, e)
    }

    func trShortDate() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMM yyyy"
        return f.string(from: self)
    }

    func trMonthTitle() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: self).capitalized(with: Locale(identifier: "tr_TR"))
    }
}
