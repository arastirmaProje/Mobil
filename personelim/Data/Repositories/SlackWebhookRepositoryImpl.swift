//
//  SlackWebhookRepositoryImpl.swift
//  personelim
//
//  Created by Tuğberk Acabey on 06.05.2026.
//

import Foundation

final class SlackWebhookRepositoryImpl: SlackWebhookRepositoryProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func getIntegrations(businessId: String) async throws -> [SlackIntegration] {
        let webhooks = try await fetchWebhooks(businessId: businessId)
        return group(webhooks: webhooks)
    }

    func createIntegration(
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async throws {
        for eventType in eventTypes {
            let request = CreateSlackWebhookRequestDTO(
                businessId: businessId,
                webhookUrl: webhookUrl,
                eventType: eventType.backendValue,
                label: label
            )

            let _: IgnoredResponse = try await network.request(
                endpoint: .createSlackWebhook,
                method: .post,
                body: request
            )
        }
    }

    func updateIntegration(
        _ integration: SlackIntegration,
        businessId: String,
        label: String,
        webhookUrl: String,
        eventTypes: [SlackActivityType]
    ) async throws {
        let selectedTypes = Set(eventTypes)
        let existingByType = Dictionary(
            integration.records.map { ($0.activityType, $0.id) },
            uniquingKeysWith: { first, _ in first }
        )

        for eventType in eventTypes {
            if let id = existingByType[eventType] {
                let request = UpdateSlackWebhookRequestDTO(
                    webhookUrl: webhookUrl,
                    eventType: eventType.backendValue,
                    label: label
                )

                let _: IgnoredResponse = try await network.request(
                    endpoint: .updateSlackWebhook(id: id),
                    method: .put,
                    body: request
                )
            } else {
                let request = CreateSlackWebhookRequestDTO(
                    businessId: businessId,
                    webhookUrl: webhookUrl,
                    eventType: eventType.backendValue,
                    label: label
                )

                let _: IgnoredResponse = try await network.request(
                    endpoint: .createSlackWebhook,
                    method: .post,
                    body: request
                )
            }
        }

        for record in integration.records where !selectedTypes.contains(record.activityType) {
            let _: IgnoredResponse = try await network.request(
                endpoint: .deleteSlackWebhook(id: record.id),
                method: .delete,
                body: nil
            )
        }
    }

    private func fetchWebhooks(businessId: String) async throws -> [SlackWebhookDTO] {
        let payload: SlackWebhookListPayload = try await network.request(
            endpoint: .slackWebhooks(businessId: businessId),
            method: .get,
            body: nil
        )
        return payload.webhooks
    }

    private func group(webhooks: [SlackWebhookDTO]) -> [SlackIntegration] {
        let grouped = Dictionary(grouping: webhooks) { dto in
            "\(trim(dto.label))|\(trim(dto.webhookUrl))"
        }

        return grouped.compactMap { key, items in
            guard let first = items.first else { return nil }
            let label = trim(first.label)
            let webhookUrl = trim(first.webhookUrl)

            guard !label.isEmpty, !webhookUrl.isEmpty else { return nil }

            let records = items.compactMap { dto -> SlackWebhookRecord? in
                guard let activityType = SlackActivityType.fromBackendValue(dto.eventType) else {
                    return nil
                }
                return SlackWebhookRecord(id: dto.id, activityType: activityType)
            }

            let eventTypes = SlackActivityType.allCases.filter { type in
                records.contains { $0.activityType == type }
            }

            guard !eventTypes.isEmpty else { return nil }

            return SlackIntegration(
                id: key,
                label: label,
                webhookUrl: webhookUrl,
                eventTypes: eventTypes,
                records: records
            )
        }
        .sorted { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending }
    }

    private func trim(_ value: String?) -> String {
        (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
