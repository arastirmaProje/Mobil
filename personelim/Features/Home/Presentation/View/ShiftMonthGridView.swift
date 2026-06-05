import SwiftUI

struct ShiftMonthGridView: View {

    let month: Date
    let summaries: [ShiftDaySummary]
    let onTapDay: (Date) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 7
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(month.monthTitleTR())
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("Aylık mesai özeti")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

               
            }

            weekHeader

            LazyVGrid(columns: columns, spacing: 9) {
                ForEach(summaries) { item in
                    DayCircle(
                        dayNumber: item.dayNumber,
                        style: item.style,
                        isToday: Calendar.current.isDateInToday(item.date)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapDay(item.date)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var weekHeader: some View {
        let days = ["P", "S", "Ç", "P", "C", "C", "P"]

        return HStack(spacing: 0) {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 2)
    }
}

private struct DayCircle: View {

    let dayNumber: Int
    let style: ShiftDayStyle
    let isToday: Bool

    var body: some View {
        Text("\(dayNumber)")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(style.textColor)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(style.bgColor)
            )
            .overlay(
                Circle()
                    .stroke(
                        isToday ? Color.blue : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isToday ? Color.blue.opacity(0.16) : Color.clear,
                radius: 6,
                y: 3
            )
    }
}
