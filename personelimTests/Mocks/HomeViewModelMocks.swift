//
//  HomeViewModelMocks.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import Foundation
@testable import personelim

enum TestError: Error {
    case any
}

// MARK: - Task Repo Mock
final class MockTaskRepo: TaskRepositoryProtocol {

    let result: Result<[TaskEntity], Error>

    init(result: Result<[TaskEntity], Error> = .success([])) {
        self.result = result
    }

    func getMyTasks() async throws -> [TaskEntity] {
        try result.get()
    }

    func createTask(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        assignedToUserId: String
    ) async throws {
        // no-op
    }

    func updateTaskStatus(
        taskId: String,
        status: String,
        thoughts: String,
        difficulty: String
    ) async throws {
        // no-op
    }

    func deleteTask(taskId: String) async throws {
        // no-op
    }
}

final class MockScheduleRepo: ScheduleRepositoryProtocol {
    let result: Result<[TaskEntity], Error>

    init(result: Result<[TaskEntity], Error> = .success([])) {
        self.result = result
    }

    func getSchedules(businessId: String) async throws -> [TaskEntity] {
        try result.get()
    }

    func createSchedule(
        businessId: String,
        title: String,
        description: String,
        date: Date,
        activityType: ActivityType
    ) async throws {
        // no-op
    }

    func deleteSchedule(scheduleId: String) async throws {
        // no-op
    }
}

// MARK: - Shift Repo Mock
final class MockShiftRepo: ShiftRepositoryProtocol {

    let result: Result<[ShiftDTO], Error>

    init(result: Result<[ShiftDTO], Error> = .success([])) {
        self.result = result
    }

    func getMyShifts(businessId: String) async throws -> [ShiftDTO] {
        try result.get()
    }

    func createShift(_ body: CreateShiftRequestDTO) async throws {
        // no-op
    }
}

// MARK: - Business Repo Mock
final class MockBusinessRepo: BusinessRepositoryProtocol {

    let result: Result<[BusinessDTO], Error>

    init(result: Result<[BusinessDTO], Error> = .success([])) {
        self.result = result
    }

    func getBusinesses() async throws -> [BusinessDTO] {
        try result.get()
    }

    func getBusiness(businessId: String) async throws -> BusinessDTO {
        try result.get().first!
    }

    func getMyBusiness() async throws -> BusinessDTO {
        try result.get().first!
    }

    func createBusiness(request: CreateBusinessRequestDTO) async throws { }
    func createBusinessAndReturnId(request: CreateBusinessRequestDTO) async throws -> String { "mock-id" }
    func verifyBusiness(code: String) async throws -> VerifyBusinessResponseDTO {
        let json = #"{"isVerified": true}"#.data(using: .utf8)!
        return try JSONDecoder().decode(VerifyBusinessResponseDTO.self, from: json)
    }

    func updateBusiness(
        businessId: String,
        request: UpdateBusinessRequestDTO
    ) async throws -> EmptyResponse {
        EmptyResponse()
    }
}
