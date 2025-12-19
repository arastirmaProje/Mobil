//
//  MultipartFile.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 17.12.2025.
//

import Foundation

struct MultipartFile {
    let fieldName: String
    let fileName: String
    let mimeType: String
    let data: Data
}
