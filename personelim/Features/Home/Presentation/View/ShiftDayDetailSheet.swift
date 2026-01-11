//
//  ShiftDayDetailSheet.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 26.12.2025.
//

import SwiftUI

struct ShiftDayDetailSheet: View {

    let detail: ShiftDayDetail

    var body: some View {
        VStack(spacing: 16) {

            Text(detail.date.dayTitleTR())
                .font(.system(size: 18, weight: .semibold))
                .padding(.top, 24)

            Text("\(ConstantStrings.totalWorkPrefix): \(detail.totalHoursText)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, 2)

            if detail.shifts.isEmpty {
                Text(ConstantStrings.noShiftForDay)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(detail.shifts.indices, id: \.self) { i in
                            let s = detail.shifts[i]
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(s.timeRangeText)
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("\(ConstantStrings.durationPrefix): \(s.durationText)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                }
            }

            Spacer(minLength: 10)
        }
        .presentationDetents([.medium, .large])
    }
}
