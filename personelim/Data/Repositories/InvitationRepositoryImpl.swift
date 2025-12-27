//
//  InvitationRepositoryImpl.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

final class InvitationRepositoryImpl: InvitationRepositoryProtocol {

    private let network: NetworkManagerProtocol
    init(network: NetworkManagerProtocol) { self.network = network }

    func sendInvitation(businessId: String, email: String, message: String?) async throws -> SendInvitationResponseDTO {
        let body = SendInvitationRequestDTO(businessId: businessId, email: email, message: message)
        return try await network.request(
            endpoint: .sendInvitation,
            method: .post,
            body: body
        )
    }
}
