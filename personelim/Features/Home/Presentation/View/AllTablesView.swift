//
//  UntitleAllTablesView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 26.12.2025.
//

import SwiftUI

struct AllTablesView: View {

    let businessId: String?
    let repo: ShiftRepositoryProtocol

    @Environment(\.dismiss) private var dismiss

    @State private var months: [Date] = []
    @State private var monthSummaries: [String: [ShiftDaySummary]] = [:]
    @State private var selectedDayDetail: ShiftDayDetail?

    enum MonthSort: String, CaseIterable, Identifiable {
        case newestFirst = "Yeni → Eski"
        case oldestFirst = "Eski → Yeni"
        var id: String { rawValue }
    }
    @State private var sort: MonthSort = .newestFirst

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    Text(ConstantStrings.allTablesTitle)
                        .font(.system(size: 22, weight: .semibold))
                        .padding(.horizontal, 16)

                    ForEach(sortedMonths, id: \.self) { m in
                        let key = m.monthKey()

                        ShiftMonthGridView(
                            month: m,
                            summaries: monthSummaries[key] ?? ShiftCalendarMapper.makeMonthSummaries(month: m, shifts: []),
                            onTapDay: { day in
                                let dayKey = day.dayKey()
                                let summary = (monthSummaries[key] ?? []).first(where: { $0.dayKey == dayKey })
                                if let summary {
                                    selectedDayDetail = ShiftDayDetail(
                                        id: dayKey,
                                        date: day,
                                        totalHoursText: summary.totalHoursText,
                                        shifts: summary.shifts
                                    )
                                }
                            }
                        )
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.top, 10)
            }
            .task {
                await loadAll()
            }
            .sheet(item: $selectedDayDetail) { detail in
                ShiftDayDetailSheet(detail: detail)
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
                    Menu {
                        Picker(ConstantStrings.sortTitle, selection: $sort) {
                            ForEach(MonthSort.allCases) { opt in
                                Text(opt.rawValue).tag(opt)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
        }
    }

    private var sortedMonths: [Date] {
        switch sort {
        case .newestFirst: return months.sorted(by: { $0 > $1 })
        case .oldestFirst: return months.sorted(by: { $0 < $1 })
        }
    }

    // MARK: - Load
    private func loadAll() async {
        guard let businessId else { return }

        months = Date.makeRecentMonths(count: 3)

        do {
            let allShifts = try await repo.getMyShifts(businessId: businessId)

            for m in months {
                let range = m.monthDateRange()

                let filtered = allShifts.filter { s in
                    guard let start = Date.isoToDate(s.startTime) else { return false }
                    return (start >= range.start) && (start < range.end)
                }

                monthSummaries[m.monthKey()] = ShiftCalendarMapper.makeMonthSummaries(
                    month: m,
                    shifts: filtered
                )
            }
        } catch {
            for m in months {
                monthSummaries[m.monthKey()] = ShiftCalendarMapper.makeMonthSummaries(
                    month: m,
                    shifts: []
                )
            }
        }
    }
}
