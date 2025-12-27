//
//  ShiftStore.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

final class ShiftStore {

    static let shared = ShiftStore()
    private init() {}

    private let key = "shift_pause_state_json"

    func save(_ state: ShiftPauseStateDTO) {
        guard let data = try? JSONEncoder().encode(state),
              let json = String(data: data, encoding: .utf8)
        else { return }
        UserDefaults.standard.set(json, forKey: key)
    }

    func load() -> ShiftPauseStateDTO? {
        guard let json = UserDefaults.standard.string(forKey: key),
              let data = json.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(ShiftPauseStateDTO.self, from: data)
        else { return nil }
        return decoded
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
