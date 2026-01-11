//
//  DateTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import Foundation

extension Date {
    static func make(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day
            )
        )!
    }
}

