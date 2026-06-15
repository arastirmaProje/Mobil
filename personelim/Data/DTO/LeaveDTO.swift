//
//  LeaveDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 30.12.2025.
//

import Foundation

struct LeaveDTO: Decodable {
    let id: String
    let title: String
    let description: String?
    let startDate: Date
    let endDate: Date
    let dayCount: Int
    let status: LeaveStatus
    let rejectionReason: String?
    let memberName: String?

    private enum CodingKeys: String, CodingKey {
        case id, title, description, startDate, endDate, dayCount, status, rejectionReason,memberName
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try c.decode(String.self, forKey: .id)
        self.title = try c.decodeIfPresent(String.self, forKey: .title) ?? "-"
        self.description = try c.decodeIfPresent(String.self, forKey: .description)
        self.dayCount = try c.decodeIfPresent(Int.self, forKey: .dayCount) ?? 0
        self.status = try c.decodeIfPresent(LeaveStatus.self, forKey: .status) ?? .pending
        self.rejectionReason = try c.decodeIfPresent(String.self, forKey: .rejectionReason)
        self.memberName = try c.decodeIfPresent(String.self, forKey: .memberName)

        let startStr = try c.decode(String.self, forKey: .startDate)
        let endStr = try c.decode(String.self, forKey: .endDate)

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let d1 = iso.date(from: startStr) {
            self.startDate = d1
        } else {
            let iso2 = ISO8601DateFormatter()
            iso2.formatOptions = [.withInternetDateTime]
            self.startDate = iso2.date(from: startStr) ?? .now
        }

        if let d2 = iso.date(from: endStr) {
            self.endDate = d2
        } else {
            let iso2 = ISO8601DateFormatter()
            iso2.formatOptions = [.withInternetDateTime]
            self.endDate = iso2.date(from: endStr) ?? .now
        }
    }
}
