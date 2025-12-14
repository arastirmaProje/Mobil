//
//  NetworkManagerProtocol.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import Foundation

protocol NetworkManagerProtocol {
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: Encodable?
    ) async throws -> T
}
