//
//  UserRole.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

enum UserRole: String, Codable, CaseIterable {
    case `default` = "Default"
    case owner = "Owner"
    case manager = "Manager"
    case employee = "Employee"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let s = try? container.decode(String.self) {
            if let i = Int(s) {
                self = Self.fromInt(i)
                return
            }
            self = UserRole(rawValue: s) ?? .default
            return
        }

        if let i = try? container.decode(Int.self) {
            self = Self.fromInt(i)
            return
        }

        self = .default
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    private static func fromInt(_ i: Int) -> UserRole {
        switch i {
        case 0: return .owner
        case 1: return .manager
        case 2: return .employee
        default: return .default
        }
    }

    var canSeePersonnelTab: Bool {
        switch self {
        case .owner, .manager:
            return true
        default:
            return false
        }
    }
}
