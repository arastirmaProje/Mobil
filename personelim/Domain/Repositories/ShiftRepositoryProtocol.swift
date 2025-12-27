//
//  ShiftRepositoryProtocol.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

protocol ShiftRepositoryProtocol {
    func createShift(_ body: CreateShiftRequestDTO) async throws
    func getMyShifts(businessId: String) async throws -> [ShiftDTO]
}
