//
//  NetworkManager.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

//
//  NetworkManager.swift
//  personelim
//

import Foundation

final class NetworkManager: NetworkManagerProtocol {

    private let baseURL = "https://personelimapi.onrender.com"

    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: Encodable?
    ) async throws -> T {

        // 1) URL
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        // 2) Body encode
        if let body = body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        // 3) Request
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        print("🔵 REQUEST:", endpoint.path)
        print("📤 BODY:", body ?? "NO BODY")
        print("📥 RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "NO DATA")

        // 4) HTTP Response
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            print("❌ HTTP ERROR:", http.statusCode)
            throw URLError(.badServerResponse)
        }

        // 5) Decode
        return try JSONDecoder().decode(T.self, from: data)
    }
}
