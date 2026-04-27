//
//  ScheduleRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 26.04.2026.
//

import Foundation

final class ScheduleRepositoryImpl: ScheduleRepositoryProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    func getSchedules(businessId: String) async throws -> [TaskEntity] {
        let response: ScheduleListResponse = try await network.request(
            endpoint: .schedules(businessId: businessId),
            method: .get,
            body: nil
        )

        return response.items.map { $0.toEntity() }
    }

    func createSchedule(
        businessId: String,
        title: String,
        description: String,
        date: Date,
        activityType: ActivityType
    ) async throws {
        let body = CreateScheduleRequestDTO(
            businessId: businessId,
            title: title,
            description: description,
            date: date,
            activityType: activityType
        )

        let _: IgnoredResponse = try await network.request(
            endpoint: .createSchedule,
            method: .post,
            body: body
        )
    }

    func deleteSchedule(scheduleId: String) async throws {
        let _: IgnoredResponse = try await network.request(
            endpoint: .deleteSchedule(scheduleId: scheduleId),
            method: .delete,
            body: nil
        )
    }
}

private struct ScheduleListResponse: Decodable {
    let items: [ScheduleDTO]

    init(from decoder: Decoder) throws {
        if let service = try? ServiceResponse<[ScheduleDTO]>(from: decoder) {
            items = service.data ?? []
            return
        }
        if let array = try? [ScheduleDTO](from: decoder) {
            items = array
            return
        }
        items = []
    }
}
