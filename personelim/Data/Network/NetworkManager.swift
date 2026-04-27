//
//  NetworkManager.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import Foundation

final class NetworkManager: NetworkManagerProtocol {

    private let baseURL = "http://178.104.144.148:8080"

    // MARK: - Errors
    struct NetworkError: LocalizedError {
        let statusCode: Int
        let body: String

        var errorDescription: String? {
            if body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "HTTP hata kodu: \(statusCode)"
            }
            return "HTTP hata kodu: \(statusCode) - \(body)"
        }
    }

    // MARK: - NORMAL REQUEST (JSON)
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        body: Encodable?
    ) async throws -> T {

        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = TokenStore.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if (method == .post || method == .put), let body = body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        } else {
            request.httpBody = nil
        }

        if let bodyData = request.httpBody {
            if let obj = try? JSONSerialization.jsonObject(with: bodyData),
               let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
               let json = String(data: pretty, encoding: .utf8) {
                print("JSON BODY :\n\(json)")
            } else {
                print("JSON BODY:", String(data: bodyData, encoding: .utf8) ?? "non-utf8")
            }
        } else {
            print("JSON BODY: nil")
        }

        print("REQUEST:", endpoint.path)
        print("BODY OBJECT:", body ?? "NO BODY")

        let (data, response) = try await URLSession.shared.data(for: request)

        print("RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "NO DATA")

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? ""
            print("HTTP ERROR:", http.statusCode, bodyText)
            throw NetworkError(statusCode: http.statusCode, body: bodyText)
        }

        do {
            let effectiveData: Data

            // Some endpoints (notably schedules create/delete) may return empty 2xx bodies.
            // JSONDecoder can't decode from an empty buffer, so we coerce empty/whitespace
            // responses into an empty JSON object.
            if data.isEmpty || data.allSatisfy({ b in
                b == 0x20 /* space */ ||
                b == 0x0A /* \n */ ||
                b == 0x0D /* \r */ ||
                b == 0x09 /* \t */
            }) {
                effectiveData = Data("{}".utf8)
            } else {
                effectiveData = data
            }

            let decoded = try JSONDecoder().decode(T.self, from: effectiveData)
            return decoded
        } catch {
            print("DECODING ERROR:", error)
            print("DECODING TYPE:", String(describing: T.self))
            print("RAW RESPONSE AGAIN:", String(data: data, encoding: .utf8) ?? "NO DATA")
            throw error
        }
    }

    // MARK: - MULTIPART (UPLOAD)
    func uploadMultipart<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod,
        fields: [String : String],
        files: [MultipartFile]
    ) async throws -> T {

        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = TokenStore.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        for (k, v) in fields {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n")
            body.appendString("\(v)\r\n")
        }

        for f in files {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(f.fieldName)\"; filename=\"\(f.fileName)\"\r\n")
            body.appendString("Content-Type: \(f.mimeType)\r\n\r\n")
            body.append(f.data)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body

        print("MULTIPART REQUEST:", endpoint.path)
        print("FIELDS:", fields)
        print("FILES:", files.map { "\($0.fieldName)=\($0.fileName) size=\($0.data.count) mime=\($0.mimeType)" })
        print("TOKEN:", TokenStore.shared.token ?? "NO TOKEN")

        let (data, response) = try await URLSession.shared.data(for: request)

        print(" RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "NO DATA")

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            print("HTTP ERROR:", http.statusCode)
            throw URLError(.init(rawValue: http.statusCode))
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print(" MULTIPART DECODING ERROR:", error)
            throw error
        }
    }

    // MARK: - DOWNLOAD (PDF)
    func downloadData(endpoint: Endpoint, method: HTTPMethod? = nil) async throws -> Data {

        guard let url = URL(string: baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = (method ?? endpoint.method).rawValue
        request.setValue("application/pdf", forHTTPHeaderField: "Accept")

        if let token = TokenStore.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("DOWNLOAD REQUEST:", endpoint.path)
        print("TOKEN:", TokenStore.shared.token ?? "NO TOKEN")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let contentType = http.value(forHTTPHeaderField: "Content-Type") ?? "-"
        print("DOWNLOAD STATUS:", http.statusCode, "Content-Type:", contentType, "Size:", data.count)

        if !(200...299).contains(http.statusCode) {
            let msg = String(data: data, encoding: .utf8) ?? "non-utf8"
            print("DOWNLOAD BODY:", msg)
            throw NSError(domain: "download", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Download hata kodu: \(http.statusCode) - \(msg)"
            ])
        }

        return data
    }

    // MARK: - HELPERS
    private struct AnyEncodable: Encodable {
        private let encodeFunc: (Encoder) throws -> Void
        init(_ value: Encodable) { self.encodeFunc = value.encode }
        func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
    }

    func absoluteURL(from pathOrUrl: String?) -> URL? {
        guard var s = pathOrUrl, !s.isEmpty else { return nil }
        if s.lowercased().hasPrefix("http") { return URL(string: s) }
        if !s.hasPrefix("/") { s = "/" + s }
        return URL(string: baseURL + s)
    }

    func cacheBusted(_ url: URL?) -> URL? {
        guard let url else { return nil }
        var c = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var items = c?.queryItems ?? []
        items.append(URLQueryItem(name: "t", value: String(Int(Date().timeIntervalSince1970))))
        c?.queryItems = items
        return c?.url
    }
}

// MARK: - DATA EXT
private extension Data {
    mutating func appendString(_ s: String) {
        if let d = s.data(using: .utf8) { append(d) }
    }
}
