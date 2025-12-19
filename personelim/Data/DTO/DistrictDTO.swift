//
//  DistrictDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

struct DistrictDTO: Codable, Identifiable {
    let id: Int
    let name: String
    let provinceId: Int?
}

typealias DistrictListResponseDTO = ServiceResponse<[DistrictDTO]>
