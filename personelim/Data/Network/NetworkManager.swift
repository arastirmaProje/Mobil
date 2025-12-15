//
//  NetworkManager.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//
import Foundation

final class NetworkManager: NetworkManagerProtocol {

    private let baseURL = "https://personelimapi.onrender.com"

    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: Encodable?
    ) async throws -> T {

        // URL
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // AUTH HEADER
        if let token = TokenStore.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Body
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // DEBUG LOG
        print("🔵 REQUEST:", endpoint.path)
        print("📤 BODY:", body ?? "NO BODY")
        print("🔐 TOKEN:", TokenStore.shared.token ?? "NO TOKEN")

        // Network call
        let (data, response) = try await URLSession.shared.data(for: request)

        print("📥 RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "NO DATA")

        // HTTP Check
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            print("❌ HTTP ERROR:", http.statusCode)
            throw URLError(.init(rawValue: http.statusCode))
        }

        // Decode
        return try JSONDecoder().decode(T.self, from: data)
    }
}
