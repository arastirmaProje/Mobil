//
//  TaskStatus.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 9.01.2026.
//

import Foundation

enum TaskStatus: String {
    case beklemede = "Beklemede"
    case done = "DONE"
    case closed = "CLOSED"

    init?(_ value: String) {
        switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "beklemede", "pending":
            self = .beklemede
        case "done", "tamamlandı", "tamamlandi", "completed":
            self = .done
        case "closed", "kapandı", "kapandi", "tamamlanmadı", "tamamlanmadi":
            self = .closed
        default:
            return nil
        }
    }
}
