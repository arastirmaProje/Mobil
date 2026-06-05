import SwiftUI
import CryptoKit

enum DepartmentColorService {

    static let palette: [Color] = [
        .blue,
        .green,
        .orange,
        .purple,
        .pink,
        .teal,
        .indigo,
        .red,
        .yellow,
        .mint,
        .cyan,
        .brown,
        .gray,
        .cyan.opacity(0.7),
        .pink.opacity(0.8),
        .purple.opacity(0.7),
        .blue.opacity(0.7),
        .green.opacity(0.7),
        .orange.opacity(0.7),
        .indigo.opacity(0.7)
    ]

    static func color(for name: String) -> Color {
        let index = stableHash(name) % palette.count
        return palette[index]
    }

    private static func stableHash(_ string: String) -> Int {
        let data = Data(string.utf8)
        let hash = SHA256.hash(data: data)

        // İlk 8 byte al → Int yap
        let value = hash.prefix(8).reduce(0) {
            ($0 << 8) | Int($1)
        }

        return abs(value)
    }
}
