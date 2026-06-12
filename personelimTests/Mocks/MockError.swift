//
//  MockError.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 12.06.2026.
//

import Foundation

enum MockError: LocalizedError {
    case sample

    var errorDescription: String? {
        "Test Error"
    }
}
