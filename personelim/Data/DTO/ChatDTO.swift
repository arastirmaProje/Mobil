//
//  ChatDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 13.06.2026.
//

import Foundation

// MARK: - Request

struct ChatSendRequestDTO: Encodable {
    let conversationId: String?
    let businessId: String
    let departmanId: String?
    let calisanId: String?
    let mesaj: String
}

// MARK: - Send Response

struct ChatSendResponseDTO: Decodable {
    let conversationId: String?
    let yanit: String?
    let islemYapildi: String?
    let veri: ChatVeriDTO?
}

// MARK: - Flexible Veri

enum ChatVeriDTO: Decodable {
    case object(ChatResponseDataDTO)
    case tasks([ChatTaskDTO])
    case string(String)
    case empty

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .empty
        } else if let tasks = try? container.decode([ChatTaskDTO].self) {
            self = .tasks(tasks)
        } else if let object = try? container.decode(ChatResponseDataDTO.self) {
            self = .object(object)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            self = .empty
        }
    }
}

// MARK: - Response Data

struct ChatResponseDataDTO: Decodable {
    let calisanId: String?
    let performansSkoru: Double?
    let raporOzeti: String?
    let detayliRapor: String?
    let departmanId: String?
    let departmanSkoru: Double?
    let calisanSayisi: Int?
    let mesaj: String?

    enum CodingKeys: String, CodingKey {
        case calisanId = "calisan_id"
        case performansSkoru = "performans_skoru"
        case raporOzeti = "rapor_ozeti"
        case detayliRapor = "detayli_rapor"
        case departmanId = "departman_id"
        case departmanSkoru = "departman_skoru"
        case calisanSayisi = "calisan_sayisi"
        case mesaj
    }
}

// MARK: - Task Data

struct ChatTaskDTO: Decodable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let assignedToName: String?
    let assignedByName: String?
    let startDate: String?
    let endDate: String?
    let status: String?
    let difficulty: String?
    let thoughts: String?
    let isOverdue: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case title = "Title"
        case description = "Description"
        case assignedToName = "AssignedToName"
        case assignedByName = "AssignedByName"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case status = "Status"
        case difficulty = "Difficulty"
        case thoughts = "Thoughts"
        case isOverdue = "IsOverdue"
        case createdAt = "CreatedAt"
    }
}

// MARK: - Conversation List

struct ChatConversationDTO: Decodable, Identifiable {
    let id: String
    let chatType: String?
    let title: String?
    let businessId: String?
    let departmentId: String?
    let createdAt: String?
    let updatedAt: String?
    let messageCount: Int?
    let lastMessagePreview: String?

    var lastMessage: String? {
        lastMessagePreview
    }
}

// MARK: - Conversation Detail

struct ChatConversationDetailDTO: Decodable {
    let id: String
    let chatType: String?
    let title: String?
    let businessId: String?
    let departmentId: String?
    let createdAt: String?
    let updatedAt: String?
    let messages: [ChatMessageDTO]
}

// MARK: - Message

struct ChatMessageDTO: Decodable, Identifiable {
    let id: String
    let role: String?
    let content: String?
    let islemYapildi: String?
    let veri: ChatVeriDTO?
    let createdAt: String?

    var message: String? {
        content
    }
}
