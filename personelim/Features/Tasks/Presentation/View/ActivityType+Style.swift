//
//  ActivityType+Style.swift
//  personelim
//
//  Created by Tuğberk Acabey on 26.04.2026.
//

import SwiftUI

extension ActivityType {
    var color: Color {
        switch self {
        case .meeting:
            return .blue
        case .task:
            return .yellow
        case .event:
            return .orange
        }
    }
}
