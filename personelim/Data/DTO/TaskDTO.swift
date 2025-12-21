//
//  TaskDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 20.12.2025.
//

import Foundation

struct TaskDTO: Decodable {
    let id: String
    let title: String?
    let description: String?
    let assignedToName: String?
    let assignedByName: String?
    let startDate: String
    let endDate: String
    let status: String
    let difficulty: String?
    let thoughts: String?
    let isOverdue: Bool
    let createdAt: String
}
