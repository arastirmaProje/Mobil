//
//  ShiftRepositoryImpl.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

final class ShiftRepositoryImpl: ShiftRepositoryProtocol {

    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    func createShift(_ body: CreateShiftRequestDTO) async throws {
        let res: ServiceResponse<EmptyResponse> = try await network.request(
            endpoint: .createShift,
            method: .post,
            body: body
        )

        if res.success == false {
            throw NSError(domain: "shift", code: -1, userInfo: [
                NSLocalizedDescriptionKey: res.message ?? "Mesai kaydı oluşturulamadı."
            ])
        }
    }

    func getMyShifts(businessId: String) async throws -> [ShiftDTO] {
        let res: ServiceResponse<[ShiftDTO]> = try await network.request(
            endpoint: .myShifts(businessId: businessId),
            method: .get,
            body: nil
        )
        return res.data ?? []
    }
}
