//
//  PerformanceQueryView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import SwiftUI

@available(iOS 17.0, *)
struct PerformanceQueryView: View {

    @Environment(\.dismiss) private var dismiss

    let businessId: String
    let employeeUserId: String
    let onCreated: (PerformanceReportDTO) -> Void

    @StateObject private var vm: PerformanceQueryViewModel

    @State private var startDate: Date?
    @State private var endDate: Date?

    init(
        businessId: String,
        employeeUserId: String,
        onCreated: @escaping (PerformanceReportDTO) -> Void
    ) {
        self.businessId = businessId
        self.employeeUserId = employeeUserId
        self.onCreated = onCreated

        let repo = PerformanceRepositoryImpl(network: NetworkManager())
        let useCase = QueryPerformanceUseCase(repo: repo)
        _vm = StateObject(wrappedValue: PerformanceQueryViewModel(queryUseCase: useCase))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text(ConstantStrings.performanceQueryTitle)
                            .font(.title.bold())
                        
                        Text(ConstantStrings.performanceQuerySubtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    RangeCalendarCard(
                        startDate: $startDate,
                        endDate: $endDate
                    )

                    HStack(spacing: 24) {
                        VStack(alignment: .leading) {
                            Text(ConstantStrings.startTitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(startDate?.trShortDate() ?? "-")
                                .font(.body.bold())
                        }

                        VStack(alignment: .leading) {
                            Text(ConstantStrings.endTitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(endDate?.trShortDate() ?? "-")
                                .font(.body.bold())
                        }
                    }
                    .padding(.horizontal)

                    if let err = vm.errorMessage {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.system(size: 13))
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            guard let s = startDate, let e = endDate else { return }
                            vm.startDate = s
                            vm.endDate = e
                            if let report = await vm.submit(
                                businessId: businessId,
                                employeeUserId: employeeUserId
                            ) {
                                onCreated(report)
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                    }
                    .disabled(vm.isLoading || startDate == nil || endDate == nil)
                }
            }
        }
    }
}

// MARK: - RangeCalendarCard

@available(iOS 17.0, *)
private struct RangeCalendarCard: View {

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
                // ConstantStrings.weekdaysShort kullanıldı
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
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .padding(.horizontal)
    }

    private func handleTap(_ day: Date) {
        let d = day.stripTime()

        if startDate == nil || (!isSelectingEnd) {
            startDate = d
            endDate = d
            isSelectingEnd = true
            return
        }

        guard let s = startDate else { return }

        if d < s {
            startDate = d
            endDate = s
        } else if d > s {
            startDate = s
            endDate = d
        } else {
            startDate = nil
            endDate = nil
            isSelectingEnd = false
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
// ... DayCell ve Date extension kısımları aynı kalıyor.

// MARK: - DayCell

@available(iOS 17.0, *)
private struct DayCell: View {

    let day: Date
    let visibleMonth: Date
    let start: Date?
    let end: Date?

    var body: some View {
        let isInMonth = day.isSameMonth(as: visibleMonth)
        let isStart = start != nil && day.stripTime() == start!.stripTime()
        let isEnd = end != nil && day.stripTime() == end!.stripTime()
        let inRange = start != nil && end != nil && day.isBetweenInclusive(start: start!, end: end!)
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

// MARK: - Date Helpers

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
        return d >= min(start, end) && d <= max(start, end)
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
