//
//  ChatRepositoryImpl.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 13.06.2026.
//

import Foundation

final class ChatRepositoryImpl: ChatRepositoryProtocol {

    private let network: NetworkManagerProtocol

    init(
        network: NetworkManagerProtocol = NetworkManager.shared
    ) {
        self.network = network
    }

    // MARK: - Personel Chat

    func sendPersonnelMessage(
        request: ChatSendRequestDTO
    ) async throws -> ChatSendResponseDTO {

        let response: ServiceResponse<ChatSendResponseDTO> =
        try await network.request(
            endpoint: .chatPersonel,
            method: .post,
            body: request
        )

        guard response.success,
              let data = response.data
        else {
            throw RepositoryError.api(
                message: response.message ?? "Mesaj gönderilemedi"
            )
        }

        return data
    }

    // MARK: - Yönetici Chat

    func sendManagerMessage(
        request: ChatSendRequestDTO
    ) async throws -> ChatSendResponseDTO {

        let response: ServiceResponse<ChatSendResponseDTO> =
        try await network.request(
            endpoint: .chatYonetici,
            method: .post,
            body: request
        )

        guard response.success,
              let data = response.data
        else {
            throw RepositoryError.api(
                message: response.message ?? "Mesaj gönderilemedi"
            )
        }

        return data
    }

    // MARK: - Conversations

    func fetchConversations() async throws -> [ChatConversationDTO] {

        let response: ServiceResponse<[ChatConversationDTO]> =
        try await network.request(
            endpoint: .chatConversations,
            method: .get,
            body: nil
        )

        return response.data ?? []
    }

    // MARK: - Conversation Detail

    func fetchConversationDetail(
        conversationId: String
    ) async throws -> ChatConversationDetailDTO {

        let response: ServiceResponse<ChatConversationDetailDTO> =
        try await network.request(
            endpoint: .chatConversationDetail(
                conversationId: conversationId
            ),
            method: .get,
            body: nil
        )

        guard response.success,
              let data = response.data
        else {
            throw RepositoryError.api(
                message: response.message ?? "Konuşma alınamadı"
            )
        }

        return data
    }

    // MARK: - Delete Conversation

    func deleteConversation(
        conversationId: String
    ) async throws {

        let response: ServiceResponse<Bool> =
        try await network.request(
            endpoint: .deleteChatConversation(
                conversationId: conversationId
            ),
            method: .delete,
            body: nil
        )

        guard response.success else {
            throw RepositoryError.api(
                message: response.message ?? "Silme işlemi başarısız"
            )
        }
    }
}
