//
//  Office.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

struct Office: Identifiable {
    let id: UUID = UUID()
    var index: Int
    var name: String
    var address: String
    var latitude: Double?
    var longitude: Double?
}

