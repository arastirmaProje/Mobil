//
//  ChatViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 13.06.2026.
//

import Foundation

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var messages: [ChatMessageEntity] = []
    @Published var conversations: [ChatConversationDTO] = []

    @Published var messageText: String = ""
    @Published var conversationId: String?

    @Published var isLoading = false
    @Published var isConversationsLoading = false
    @Published var errorMessage: String?

    private let repository: ChatRepositoryProtocol

    init(
        repository: ChatRepositoryProtocol = ChatRepositoryImpl()
    ) {
        self.repository = repository

        messages = [
            ChatMessageEntity(
                text: ConstantStrings.chatWelcomeSubtitle,
                isUser: false
            )
        ]
    }

    func sendMessage(
        businessId: String,
        departmentId: String?,
        employeeUserId: String?,
        isManager: Bool
    ) async {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return
        }

        errorMessage = nil

        messages.append(
            ChatMessageEntity(
                text: trimmed,
                isUser: true
            )
        )

        messageText = ""
        isLoading = true

        let request = ChatSendRequestDTO(
            conversationId: conversationId,
            businessId: businessId,
            departmanId: departmentId,
            calisanId: employeeUserId,
            mesaj: trimmed
        )

        do {
            let response: ChatSendResponseDTO

            if isManager {
                response = try await repository.sendManagerMessage(
                    request: request
                )
            } else {
                response = try await repository.sendPersonnelMessage(
                    request: request
                )
            }

            if let newConversationId = response.conversationId {
                conversationId = newConversationId
            }

            messages.append(
                ChatMessageEntity(
                    text: response.yanit ?? ConstantStrings.dashPlaceholder,
                    isUser: false
                )
            )
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.chatSendFailed
            )
        }

        isLoading = false
    }

    func loadConversations() async {
        isConversationsLoading = true

        defer {
            isConversationsLoading = false
        }

        do {
            conversations = try await repository.fetchConversations()
        } catch {
            conversations = []
        }
    }

    func loadConversationDetail(
        conversationId: String
    ) async {
        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let detail = try await repository.fetchConversationDetail(
                conversationId: conversationId
            )

            self.conversationId = detail.id

            messages = detail.messages.map { dto in
                ChatMessageEntity(
                    id: dto.id,
                    text: dto.message ?? ConstantStrings.dashPlaceholder,
                    isUser: isUserRole(dto.role),
                    createdAt: parseDate(dto.createdAt)
                )
            }
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.chatConversationLoadFailed
            )
        }
    }

    func deleteConversation(
        conversationId: String
    ) async {
        do {
            try await repository.deleteConversation(
                conversationId: conversationId
            )

            conversations.removeAll { $0.id == conversationId }

            if self.conversationId == conversationId {
                self.conversationId = nil
                messages = [
                    ChatMessageEntity(
                        text: ConstantStrings.chatWelcomeSubtitle,
                        isUser: false
                    )
                ]
            }
        } catch {
            errorMessage = userMessage(
                from: error,
                fallback: ConstantStrings.chatDeleteFailed
            )
        }
    }

    private func isUserRole(_ role: String?) -> Bool {
        let value = role?.lowercased() ?? ""

        return value == "user"
            || value == "kullanici"
            || value == "kullanıcı"
            || value == "personel"
            || value == "yonetici"
            || value == "yönetici"
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value else {
            return nil
        }

        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = fractional.date(from: value) {
            return date
        }

        return ISO8601DateFormatter().date(from: value)
    }

    private func userMessage(
        from error: Error,
        fallback: String
    ) -> String {
        if case let RepositoryError.api(message) = error {
            return message
        }

        return fallback
    }
}
