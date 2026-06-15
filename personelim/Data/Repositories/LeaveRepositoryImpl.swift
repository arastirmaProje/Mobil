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

    // MARK: - My Leaves

    func getMyLeaves(businessId: String) async throws -> [LeaveEntity] {
        let response: ServiceResponse<[LeaveDTO]> = try await network.request(
            endpoint: .myLeaves(businessId: businessId),
            method: .get,
            body: nil
        )

        guard response.success else {
            throw RepositoryError.api(
                message: response.message ?? ConstantStrings.leaveRequestsLoadFailed
            )
        }

        return (response.data ?? []).map { dto in
            LeaveEntity(
                id: dto.id,
                title: dto.title,
                description: dto.description,
                startDate: dto.startDate,
                endDate: dto.endDate,
                status: dto.status,
                dayCount: dto.dayCount,
                rejectionReason: dto.rejectionReason
            )
        }
    }

    // MARK: - Business Leaves

    func getBusinessLeaves(businessId: String) async throws -> [LeaveDTO] {
        let response: ServiceResponse<[LeaveDTO]> = try await network.request(
            endpoint: .businessLeaves(businessId: businessId),
            method: .get,
            body: nil
        )

        guard response.success, let data = response.data else {
            throw RepositoryError.api(
                message: response.message ?? ConstantStrings.leaveRequestsLoadFailed
            )
        }

        return data
    }

    // MARK: - Create Leave

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

        let response: ServiceResponse<EmptyResponse> = try await network.request(
            endpoint: .createLeave,
            method: .post,
            body: body
        )

        guard response.success else {
            throw RepositoryError.api(
                message: response.message ?? ConstantStrings.leaveCreateFailed
            )
        }
    }

    // MARK: - Update Leave Status

    func updateLeaveStatus(
        leaveId: String,
        status: Int,
        rejectionReason: String?
    ) async throws {

        let body = UpdateLeaveStatusRequestDTO(
            status: status,
            rejectionReason: rejectionReason
        )

        let response: ServiceResponse<EmptyResponse> = try await network.request(
            endpoint: .updateLeaveStatus(leaveId: leaveId),
            method: .put,
            body: body
        )

        guard response.success else {
            throw RepositoryError.api(
                message: response.message ?? ConstantStrings.leaveStatusUpdateFailed
            )
        }
    }
}
