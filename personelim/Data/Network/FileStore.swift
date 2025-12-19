//
//  FileStore.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 18.12.2025.
//

import Foundation

enum FileStore {

    static func writeTempPDF(data: Data, fileName: String? = nil) throws -> URL {
        let safeName = (fileName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            ? fileName!
            : UUID().uuidString

      
        let finalName: String = safeName.lowercased().hasSuffix(".pdf") ? safeName : (safeName + ".pdf")

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(finalName)

        try data.write(to: url, options: .atomic)
        return url
    }
}
