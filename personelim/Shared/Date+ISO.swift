//
//  Date+ISO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

enum ISODate {
    static func string(from date: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: date)
    }

    static func date(from value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }

        let candidates = [
            value,
            value.replacingOccurrences(of: "Z", with: "+00:00")
        ]

        let withFrac = ISO8601DateFormatter()
        withFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let noFrac = ISO8601DateFormatter()
        noFrac.formatOptions = [.withInternetDateTime]

        for c in candidates {
            if let d = withFrac.date(from: c) { return d }
            if let d = noFrac.date(from: c) { return d }
        }
        return nil
    }

    static func shortRange(start: String?, end: String?) -> String {
        guard
            let s = start, let e = end,
            let sd = ISODate.date(from: s),
            let ed = ISODate.date(from: e)
        else { return "-" }

        let df = DateFormatter()
        df.locale = Locale(identifier: "tr_TR")
        df.dateFormat = "dd/MM/yyyy"
        return "\(df.string(from: sd)) – \(df.string(from: ed))"
    }
}

extension Date {
    
    func formatToWeekDayShort() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    func formatToDayNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    func taskDayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
