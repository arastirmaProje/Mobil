import SwiftUI

struct AllTablesView: View {

    let businessId: String?
    let repo: ShiftRepositoryProtocol

    @Environment(\.dismiss) private var dismiss

    @State private var months: [Date] = Date.makeRecentMonths(count: 3)
    @State private var monthSummaries: [String: [ShiftDaySummary]] = [:]
    @State private var selectedDayDetail: ShiftDayDetail?

    @State private var isLoading = false
    @State private var errorMessage: String?

    enum MonthSort: CaseIterable, Identifiable {
        case newestFirst
        case oldestFirst

        var id: String { title }

        var title: String {
            switch self {
            case .newestFirst:
                return ConstantStrings.monthSortNewestFirst
            case .oldestFirst:
                return ConstantStrings.monthSortOldestFirst
            }
        }
    }

    @State private var sort: MonthSort = .newestFirst

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {

                        headerSection

                        if isLoading {
                            loadingCard
                        }

                        if let errorMessage {
                            errorCard(errorMessage)
                        }

                        if !isLoading && sortedMonths.isEmpty {
                            emptyState
                        } else {
                            monthsSection
                        }

                        Spacer(minLength: 28)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }
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
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(ConstantStrings.sortTitle, selection: $sort) {
                            ForEach(MonthSort.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.allTablesTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)

                Text(String(format: ConstantStrings.recentShiftCalendarsFormat, months.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            sortBadge
        }
    }

    private var sortBadge: some View {
        Text(sort.title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.blue)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.10))
            )
    }

    private var monthsSection: some View {
        VStack(spacing: 16) {
            ForEach(sortedMonths, id: \.self) { month in
                monthCard(month)
            }
        }
    }

    private func monthCard(_ month: Date) -> some View {
        let key = month.monthKey()

        let summaries = monthSummaries[key] ?? ShiftCalendarMapper.makeMonthSummaries(
            month: month,
            shifts: []
        )

        return ShiftMonthGridView(
            month: month,
            summaries: summaries,
            onTapDay: { day in
                openDayDetail(day: day, monthKey: key)
            }
        )
    }

    private func openDayDetail(day: Date, monthKey: String) {
        let dayKey = day.dayKey()

        let summary = (monthSummaries[monthKey] ?? [])
            .first(where: { $0.dayKey == dayKey })

        guard let summary else { return }

        selectedDayDetail = ShiftDayDetail(
            id: dayKey,
            date: day,
            totalHoursText: summary.totalHoursText,
            shifts: summary.shifts
        )
    }

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.shiftTablesLoading)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.25), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.blue)

            Text(ConstantStrings.shiftTableNotFoundTitle)
                .font(.headline)

            Text(ConstantStrings.shiftTableNotFoundDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var sortedMonths: [Date] {
        switch sort {
        case .newestFirst:
            return months.sorted { $0 > $1 }

        case .oldestFirst:
            return months.sorted { $0 < $1 }
        }
    }

    private func loadAll() async {
        guard let businessId else {
            errorMessage = ConstantStrings.businessInfoNotFoundError
            return
        }

        isLoading = true
        errorMessage = nil

        if months.isEmpty {
            months = Date.makeRecentMonths(count: 3)
        }

        defer {
            isLoading = false
        }

        do {
            let allShifts = try await repo.getMyShifts(businessId: businessId)

            for month in months {
                let range = month.monthDateRange()

                let filtered = allShifts.filter { shift in
                    guard let start = Date.isoToDate(shift.startTime) else {
                        return false
                    }

                    return start >= range.start && start < range.end
                }

                monthSummaries[month.monthKey()] = ShiftCalendarMapper.makeMonthSummaries(
                    month: month,
                    shifts: filtered
                )
            }
        }  catch {
            errorMessage = ConstantStrings.shiftTablesLoadFailed

            for month in months {
                monthSummaries[month.monthKey()] = ShiftCalendarMapper.makeMonthSummaries(
                    month: month,
                    shifts: []
                )
            }
        }
    }
}
