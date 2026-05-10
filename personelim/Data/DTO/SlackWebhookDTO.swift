//
//  SlackWebhookDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 07.05.2026.
//

import Foundation

struct SlackWebhookDTO: Decodable, Identifiable, Hashable {
    let id: String
    let businessId: String?
    let webhookUrl: String?
    let eventType: String?
    let label: String?
    let isActive: Bool?

    private enum CodingKeys: String, CodingKey {
        case id
        case webhookId
        case businessId
        case webhookUrl
        case eventType
        case label
        case isActive
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
            ?? container.decodeIfPresent(String.self, forKey: .webhookId)
            ?? UUID().uuidString
        businessId = try container.decodeIfPresent(String.self, forKey: .businessId)
        webhookUrl = try container.decodeIfPresent(String.self, forKey: .webhookUrl)
        eventType = try container.decodeIfPresent(String.self, forKey: .eventType)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
    }
}

struct CreateSlackWebhookRequestDTO: Encodable {
    let businessId: String
    let webhookUrl: String
    let eventType: String
    let label: String
}

struct UpdateSlackWebhookRequestDTO: Encodable {
    let webhookUrl: String
    let eventType: String
    let label: String
}

struct SlackWebhookListPayload: Decodable {
    let webhooks: [SlackWebhookDTO]

    init(from decoder: Decoder) throws {
        if let webhooks = try? [SlackWebhookDTO](from: decoder) {
            self.webhooks = webhooks
            return
        }

        let response = try ServiceResponse<[SlackWebhookDTO]>(from: decoder)
        self.webhooks = response.data ?? []
    }
}
