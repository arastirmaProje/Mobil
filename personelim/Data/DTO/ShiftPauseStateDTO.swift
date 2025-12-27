//
//  ShiftPauseStateDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

struct ShiftPauseStateDTO: Codable {
    let startedAtIso: String
    let pausedTotalSeconds: Int
    let isPaused: Bool
    let pausedAtIso: String?
    let option: StoredShiftOption
}
