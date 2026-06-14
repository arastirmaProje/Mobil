//
//  ChatRepositoryProtocol.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 13.06.2026.
//

import Foundation

protocol ChatRepositoryProtocol {

    func sendPersonnelMessage(
        request: ChatSendRequestDTO
    ) async throws -> ChatSendResponseDTO

    func sendManagerMessage(
        request: ChatSendRequestDTO
    ) async throws -> ChatSendResponseDTO

    func fetchConversations() async throws -> [ChatConversationDTO]

    func fetchConversationDetail(
        conversationId: String
    ) async throws -> ChatConversationDetailDTO

    func deleteConversation(
        conversationId: String
    ) async throws
}
