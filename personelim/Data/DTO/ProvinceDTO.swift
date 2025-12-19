//
//  ProvinceDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//

import Foundation

struct ProvinceDTO: Codable, Identifiable {
    let id: Int
    let name: String
    let districts: [DistrictDTO]? 
}

typealias ProvinceListResponseDTO = ServiceResponse<[ProvinceDTO]>
