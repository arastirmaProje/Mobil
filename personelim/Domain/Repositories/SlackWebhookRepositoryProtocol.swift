//
//  SlackWebhookRepositoryProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 02.05.2026.
//

import Foundation

protocol SlackWebhookRepositoryProtocol {
    func getIntegrations(businessId: String) async throws -> [SlackIntegration]

    func createIntegration(
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async throws

    func updateIntegration(
        _ integration: SlackIntegration,
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async throws
}
