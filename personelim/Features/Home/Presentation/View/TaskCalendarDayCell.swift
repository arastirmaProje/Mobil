//
//  TaskCalendarDayCell.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import SwiftUI

struct TaskCalendarDayCell: View {
    let date: Date
    let activities: [ActivityType]
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text(date.formatToWeekDayShort().uppercased())
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
            
            Text(date.formatToDayNumber())
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isSelected ? .red : .primary)
            
            VStack(spacing: 6) {
                ForEach(activities, id: \.self) { type in
                    Circle()
                        .fill(type.color)
                        .frame(width: 10, height: 10)
                }
                
                if activities.isEmpty {
                    Spacer().frame(height: 10)
                }
            }
            .frame(height: 45, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }
}

