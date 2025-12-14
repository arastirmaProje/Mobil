//
//  CreateBusinessRequestDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

struct CreateBusinessRequestDTO: Encodable {
    let businessName: String
    let phoneNumber: String
    let provinceId: Int
    let districtId: Int
    let address: String
    let description: String?
    let offices: [OfficeLocationDTO]?
}
