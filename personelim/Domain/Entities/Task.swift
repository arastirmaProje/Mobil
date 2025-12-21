//
//  Task.swift
//  personelim
//
//  Created by Tuğberk Acabey on 20.12.2025.
//

import Foundation

struct TaskEntity: Identifiable {
    let id: String
    let title: String
    let description: String?
    let assignedToName: String?
    let assignedByName: String?
    let startDate: Date
    let endDate: Date
    let status: String
    let isOverdue: Bool
}
