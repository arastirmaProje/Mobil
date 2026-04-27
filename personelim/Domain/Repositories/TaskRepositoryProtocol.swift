//
//  TaskRepositoryProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 20.12.2025.
//

import Foundation

protocol TaskRepositoryProtocol {
    
    func getMyTasks() async throws -> [TaskEntity]
    
    func createTask(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        assignedToUserId: String
    ) async throws
    
    func updateTaskStatus(
            taskId: String,
            status: String,
            thoughts: String,
            difficulty: String
        ) async throws

    func deleteTask(taskId: String) async throws
}

protocol ScheduleRepositoryProtocol {
    func getSchedules(businessId: String) async throws -> [TaskEntity]

    func createSchedule(
        businessId: String,
        title: String,
        description: String,
        date: Date,
        activityType: ActivityType
    ) async throws

    func deleteSchedule(scheduleId: String) async throws
}
