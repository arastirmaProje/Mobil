//
//  OfficeLocationDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 14.12.2025.
//

import Foundation

struct OfficeLocationDTO: Encodable {
    let officeName: String?
    let latitude: Double
    let longitude: Double
}
