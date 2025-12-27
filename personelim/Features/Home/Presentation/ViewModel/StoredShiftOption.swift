//
//  StoredShiftOption.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

struct StoredShiftOption: Codable, Equatable {
    enum Kind: String, Codable { case home, office }

    let kind: Kind
    let id: String?
    let name: String?
    let lat: Double?
    let lng: Double?

    static func from(_ option: ShiftStartOption) -> StoredShiftOption {
        switch option {
        case .home:
            return .init(kind: .home, id: nil, name: nil, lat: nil, lng: nil)
        case .office(let id, let name, let lat, let lng):
            return .init(kind: .office, id: id, name: name, lat: lat, lng: lng)
        }
    }

    func toDomain() -> ShiftStartOption? {
        switch kind {
        case .home:
            return .home
        case .office:
            guard let id, let name, let lat, let lng else { return nil }
            return .office(id: id, name: name, lat: lat, lng: lng)
        }
    }
}
