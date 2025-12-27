//
//  ShiftMonthGridView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 26.12.2025.
//

import SwiftUI

struct ShiftMonthGridView: View {

    let month: Date
    let summaries: [ShiftDaySummary]
    let onTapDay: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(month.monthTitleTR())
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(summaries) { item in
                    DayCircle(
                        dayNumber: item.dayNumber,
                        style: item.style
                    )
                    .onTapGesture {
                        onTapDay(item.date)
                    }
                }
            }
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct DayCircle: View {
    let dayNumber: Int
    let style: ShiftDayStyle

    var body: some View {
        Text("\(dayNumber)")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(style.textColor)
            .frame(width: 36, height: 36)
            .background(style.bgColor)
            .clipShape(Circle())
    }
}
