//
//  TaskEntityHelper.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import Foundation
@testable import personelim

extension TaskEntity {

    static func activeMock(
        id: String = UUID().uuidString
    ) -> TaskEntity {
        TaskEntity(
            id: id,
            title: "Active Task",
            description: nil,
            assignedToName: nil,
            assignedByName: nil,
            startDate: Date().addingTimeInterval(-3600),
            endDate: Date().addingTimeInterval(86_400), // +1 gün
            status: "Beklemede",
            isOverdue: false
        )
    }

    static func pastMock(
        id: String = UUID().uuidString
    ) -> TaskEntity {
        TaskEntity(
            id: id,
            title: "Past Task",
            description: nil,
            assignedToName: nil,
            assignedByName: nil,
            startDate: Date().addingTimeInterval(-86_400),
            endDate: Date().addingTimeInterval(-3600),
            status: "Tamamlandı",
            isOverdue: false
        )
    }
}
