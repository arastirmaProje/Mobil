//
//  OfficeLocationReadDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 19.12.2025.
//

import Foundation

struct OfficeLocationReadDTO: Codable, Identifiable {
    let id: String?
    let officeName: String?
    let latitude: Double?
    let longitude: Double?
    let address: String?

    var identity: String { id ?? UUID().uuidString }
}
