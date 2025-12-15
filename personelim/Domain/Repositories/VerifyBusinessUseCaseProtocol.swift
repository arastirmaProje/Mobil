//
//  VerifyBusinessUseCaseProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 16.12.2025.
//

import Foundation

protocol VerifyBusinessUseCaseProtocol {
    func execute(code: String) async throws -> Bool
}
