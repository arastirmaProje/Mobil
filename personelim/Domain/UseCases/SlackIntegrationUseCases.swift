//
//  SlackIntegrationUseCases.swift
//  personelim
//
//  Created by Tuğberk Acabey on 02.05.2026.
//

import Foundation

final class GetSlackIntegrationsUseCase {
    private let repository: SlackWebhookRepositoryProtocol

    init(repository: SlackWebhookRepositoryProtocol) {
        self.repository = repository
    }

    func execute(businessId: String) async throws -> [SlackIntegration] {
        try await repository.getIntegrations(businessId: businessId)
    }
}

final class CreateSlackIntegrationUseCase {
    private let repository: SlackWebhookRepositoryProtocol

    init(repository: SlackWebhookRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async throws {
        try await repository.createIntegration(
            businessId: businessId,
            label: label,
            webhookUrl: webhookUrl,
            eventTypes: eventTypes
        )
    }
}

final class UpdateSlackIntegrationUseCase {
    private let repository: SlackWebhookRepositoryProtocol

    init(repository: SlackWebhookRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        integration: SlackIntegration,
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async throws {
        try await repository.updateIntegration(
            integration,
            businessId: businessId,
            label: label,
            webhookUrl: webhookUrl,
            eventTypes: eventTypes
        )
    }
}
