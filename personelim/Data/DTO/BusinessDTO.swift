//
//  BusinessDTO.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 16.12.2025.
//



import Foundation

struct BusinessDTO: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let address: String?
    let phoneNumber: String?
    let imageUrl: String?

    let locationName: String?
    let latitude: Double
    let longitude: Double

    let provinceId: Int
    let provinceName: String?
    let districtId: Int
    let districtName: String?

    let role: String?
    let memberCount: Int?
    let isSubscribed: Bool?
    let parentBusinessId: String?
    let parentBusinessName: String?
    let isSubBusiness: Bool?
    let subBusinessCount: Int?

    let createdAt: String?
    
    let offices: [OfficeLocationReadDTO]?

    
}


typealias BusinessServiceResponseDTO = ServiceResponse<BusinessDTO>
