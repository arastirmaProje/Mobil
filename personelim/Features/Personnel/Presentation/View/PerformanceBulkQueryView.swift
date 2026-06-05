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

    private var canSubmit: Bool {
        !vm.isBulkLoading
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection
                        rangeSummaryCard
                        calendarSection

                        if let error = vm.bulkError {
                            errorCard(error)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomSubmitButton
            }
            .navigationTitle(ConstantStrings.bulkQueryTitle)
            .navigationBarTitleDisplayMode(.inline)
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
            }
        }
        .onAppear {
            visibleMonth = startDate
        }
    }
}

// MARK: - Sections

private extension PerformanceBulkQueryView {

    var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.bulkQueryTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.calendarInstruction)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    var rangeSummaryCard: some View {
        HStack(spacing: 0) {
            dateSummaryBox(
                title: ConstantStrings.startTitle,
                value: startDate.trShortDate(),
                icon: "calendar.badge.play"
            )

            Divider()
                .padding(.vertical, 10)

            dateSummaryBox(
                title: ConstantStrings.endTitle,
                value: endDate.trShortDate(),
                icon: "calendar.badge.clock"
            )
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    var calendarSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tarih Aralığı")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 2)

            RangeCalendarView(
                visibleMonth: $visibleMonth,
                startDate: $startDate,
                endDate: $endDate
            )
            .disabled(vm.isBulkLoading)
            .opacity(vm.isBulkLoading ? 0.55 : 1)
        }
    }

    var bottomSubmitButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    guard !vm.isBulkLoading else { return }

                    let didComplete = await vm.runBulkQuery(
                        businessId: businessId,
                        start: startDate,
                        end: endDate
                    )

                    if didComplete {
                        onCompleted(startDate, endDate)
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if vm.isBulkLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkle.magnifyingglass")
                    }

                    Text(vm.isBulkLoading ? "Sorgulanıyor..." : ConstantStrings.bulkQueryTitle)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canSubmit ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }

    func dateSummaryBox(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
    }

    func errorCard(_ message: String) -> some View {
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
}

// MARK: - Range Calendar View

private struct RangeCalendarView: View {

    @Binding var visibleMonth: Date
    @Binding var startDate: Date
    @Binding var endDate: Date

    @State private var isSelectingEnd: Bool = false

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 7
    )

    var body: some View {
        VStack(spacing: 14) {
            calendarHeader
            weekdaysHeader
            daysGrid
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var calendarHeader: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    visibleMonth = Calendar.current.date(
                        byAdding: .month,
                        value: -1,
                        to: visibleMonth
                    ) ?? visibleMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 34, height: 34)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text(visibleMonth.trMonthTitle())
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)

                Text(isSelectingEnd ? "Bitiş tarihini seç" : "Başlangıç tarihini seç")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    visibleMonth = Calendar.current.date(
                        byAdding: .month,
                        value: 1,
                        to: visibleMonth
                    ) ?? visibleMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 34, height: 34)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var weekdaysHeader: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(ConstantStrings.weekdaysShort, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(daysForVisibleMonth(), id: \.self) { day in
                DayCell(
                    day: day,
                    visibleMonth: visibleMonth,
                    start: startDate,
                    end: endDate
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        handleTap(day)
                    }
                }
            }
        }
        .padding(.top, 2)
    }

    private func handleTap(_ day: Date) {
        let selectedDay = day.stripTime()
        let currentStart = startDate.stripTime()

        if !isSelectingEnd {
            startDate = selectedDay
            endDate = selectedDay
            isSelectingEnd = true
            return
        }

        if selectedDay < currentStart {
            startDate = selectedDay
            endDate = currentStart
        } else {
            endDate = selectedDay
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
            let offset = -(leadingEmpty - index)
            if let date = calendar.date(
                byAdding: .day,
                value: offset,
                to: startOfMonth
            ) {
                days.append(date)
            }
        }

        let range = calendar.range(
            of: .day,
            in: .month,
            for: startOfMonth
        ) ?? 1..<2

        for day in range {
            if let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: startOfMonth
            ) {
                days.append(date)
            }
        }

        while days.count < 42 {
            if let last = days.last,
               let next = calendar.date(byAdding: .day, value: 1, to: last) {
                days.append(next)
            } else {
                break
            }
        }

        return days
    }
}

// MARK: - Day Cell

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
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.blue.opacity(0.10))
            }

            if isStart || isEnd {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.blue.opacity(0.22))
            }

            if isToday {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.blue.opacity(0.45), lineWidth: 1.2)
            }

            Text("\(Calendar.current.component(.day, from: day))")
                .font(.system(size: 13, weight: (isStart || isEnd) ? .bold : .medium))
                .foregroundStyle(isInMonth ? Color.primary : Color.secondary.opacity(0.45))
                .frame(maxWidth: .infinity, minHeight: 36)
        }
        .frame(height: 36)
    }
}
