//
//  Company.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

import Foundation

struct Company: Identifiable {
    let id: String
    var name: String?
    var description: String?
    var email: String?
    var imageUrl: String?

    var phoneNumber: String?
    var address: String?
    var provinceName: String?
    var districtName: String?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?

    var offices: [Office]? = []
}
