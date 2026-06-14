//
//  ChatMessageEntity.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 13.06.2026.
//

import Foundation

struct ChatMessageEntity: Identifiable, Equatable {
    let id: String
    let text: String
    let isUser: Bool
    let createdAt: Date?

    init(
        id: String = UUID().uuidString,
        text: String,
        isUser: Bool,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.createdAt = createdAt
    }
}
