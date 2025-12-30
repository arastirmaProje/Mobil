//
//  LeaveRepositoryProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 30.12.2025.
//

import Foundation

protocol LeaveRepositoryProtocol {

    func getMyLeaves(businessId: String) async throws -> [LeaveEntity]

    func createLeave(
        businessId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date
    ) async throws

    func updateLeaveStatus(
        leaveId: String,
        status: Int,
        rejectionReason: String?
    ) async throws
}
