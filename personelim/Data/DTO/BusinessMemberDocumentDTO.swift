//
//  BusinessMemberDocumentDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 18.12.2025.
//

import Foundation

struct BusinessMemberDocumentDTO: Codable {
    let id: String
    let documentType: String
    let fileName: String
    let fileUrl: String
    let uploadedAt: String?
}
