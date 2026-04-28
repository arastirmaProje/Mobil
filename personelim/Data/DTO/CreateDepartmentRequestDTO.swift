//
//  CreateDepartmentRequestDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 27.04.2026.
//

import Foundation

struct CreateDepartmentRequestDTO: Codable {
    let name: String
    let businessId: String
    let categoryId: Int
}
