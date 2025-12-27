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

    static func shortRange(start: String?, end: String?) -> String {
        guard
            let s = start, let e = end,
            let sd = ISO8601DateFormatter().date(from: s) ?? ISO8601DateFormatter().date(from: s.replacingOccurrences(of: "Z", with: "+00:00")),
            let ed = ISO8601DateFormatter().date(from: e) ?? ISO8601DateFormatter().date(from: e.replacingOccurrences(of: "Z", with: "+00:00"))
        else { return "-" }

        let df = DateFormatter()
        df.locale = Locale(identifier: "tr_TR")
        df.dateFormat = "dd/MM/yyyy"
        return "\(df.string(from: sd)) – \(df.string(from: ed))"
    }
}
