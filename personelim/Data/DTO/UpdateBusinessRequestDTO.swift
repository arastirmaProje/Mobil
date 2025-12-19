//
//  UpdateBusinessRequestDTO.swift.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 18.12.2025.
//

import Foundation

struct UpdateBusinessRequestDTO: Encodable {
    let name: String?
    let description: String?
    let address: String?
    let phoneNumber: String?
    let locationName: String?
    let latitude: Double?
    let longitude: Double?
    let provinceId: Int?
    let districtId: Int?
    let imageData: Data?
}
