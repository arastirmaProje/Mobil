//
//  DepartmentResponseDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import Foundation

struct DepartmentResponseDTO: Codable, Hashable {
    let id: String 
    let businessId: String
    let categoryId: Int
    let name: String
    let memberCount: Int
    let createdAt: String
}
