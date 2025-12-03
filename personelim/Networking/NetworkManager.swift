//
//  NetworkManager.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import Foundation

class NetworkManager: NetworkManagerProtocol {

    let baseURL = "https://personelimapi.onrender.com"

    func login(_ request: LoginRequest) async throws -> AuthResponse {
        guard let url = URL(string: baseURL + Endpoint.login.path) else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("text/plain", forHTTPHeaderField: "Accept")  // 🔥 ÖNEMLİ
        
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "NO DATA") // DEBUG
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }

}
