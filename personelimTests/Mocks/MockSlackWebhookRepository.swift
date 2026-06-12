//
//  MockSlackWebhookRepository.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import Foundation
@testable import personelim

final class MockSlackWebhookRepository: SlackWebhookRepositoryProtocol {

    var integrationsResult: Result<[SlackIntegration], Error> = .success([])
    var createResult: Result<Void, Error> = .success(())
    var updateResult: Result<Void, Error> = .success(())

    var getIntegrationsCallCount = 0
    var createIntegrationCallCount = 0
    var updateIntegrationCallCount = 0

    var receivedBusinessId: String?

    var receivedCreateBusinessId: String?
    var receivedCreateLabel: String?
    var receivedCreateWebhookUrl: String?
    var receivedCreateEventTypes: [SlackActivityType] = []

    var receivedUpdateIntegration: SlackIntegration?
    var receivedUpdateBusinessId: String?
    var receivedUpdateLabel: String?
    var receivedUpdateWebhookUrl: String?
    var receivedUpdateEventTypes: [SlackActivityType] = []

    func getIntegrations(
        businessId: String
    ) async throws -> [SlackIntegration] {
        getIntegrationsCallCount += 1
        receivedBusinessId = businessId

        return try integrationsResult.get()
    }

    func createIntegration(
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async throws {
        createIntegrationCallCount += 1
        receivedCreateBusinessId = businessId
        receivedCreateLabel = label
        receivedCreateWebhookUrl = webhookUrl
        receivedCreateEventTypes = eventTypes

        try createResult.get()
    }

    func updateIntegration(
        _ integration: SlackIntegration,
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async throws {
        updateIntegrationCallCount += 1
        receivedUpdateIntegration = integration
        receivedUpdateBusinessId = businessId
        receivedUpdateLabel = label
        receivedUpdateWebhookUrl = webhookUrl
        receivedUpdateEventTypes = eventTypes

        try updateResult.get()
    }
}
