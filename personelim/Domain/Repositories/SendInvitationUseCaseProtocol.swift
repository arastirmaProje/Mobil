//
//  SendInvitationUseCaseProtocol.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

protocol SendInvitationUseCaseProtocol {
    func execute(businessId: String, email: String, message: String?) async throws -> SendInvitationResponseDTO
}

