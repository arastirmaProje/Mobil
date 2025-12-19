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

    var canSeePersonnelTab: Bool {
        switch self {
        case .owner, .manager:
            return true
        default:
            return false
        }
    }
}
