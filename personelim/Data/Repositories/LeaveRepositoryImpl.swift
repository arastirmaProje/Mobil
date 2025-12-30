//
//  LeaveRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 30.12.2025.
//

import Foundation

final class LeaveRepositoryImpl: LeaveRepositoryProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    func getMyLeaves(businessId: String) async throws -> [LeaveEntity] {

        let response: ServiceResponse<[LeaveDTO]> = try await network.request(
            endpoint: .myLeaves(businessId: businessId),
            method: .get,
            body: nil
        )

        return (response.data ?? []).map { dto in
            LeaveEntity(
                id: dto.id,
                title: dto.title,
                description: dto.description,
                startDate: dto.startDate,
                endDate: dto.endDate,
                status: dto.status,
                dayCount: dto.dayCount
            )
        }
    }

    func createLeave(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date
    ) async throws {

        let body = CreateLeaveRequestDTO(
            businessId: businessId,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate
        )

        let _: ServiceResponse<EmptyResponse> =
            try await network.request(
                endpoint: .createLeave,
                method: .post,
                body: body
            )
    }

    func updateLeaveStatus(
        leaveId: String,
        status: Int,
        rejectionReason: String?
    ) async throws {

        let body = UpdateLeaveStatusRequestDTO(
            status: status,
            rejectionReason: rejectionReason
        )

        let _: ServiceResponse<EmptyResponse> =
            try await network.request(
                endpoint: .updateLeaveStatus(leaveId: leaveId),
                method: .put,
                body: body
            )
    }
}
