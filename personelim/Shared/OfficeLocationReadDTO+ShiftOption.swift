//
//  OfficeLocationReadDTO+ShiftOption.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

extension Array where Element == OfficeLocationReadDTO {
    func toShiftOfficeOptions() -> [ShiftStartOption] {
        compactMap { o in
            guard
                let id = o.id,
                let name = o.officeName,
                let lat = o.latitude,
                let lng = o.longitude
            else { return nil }

            return .office(id: id, name: name, lat: lat, lng: lng)
        }
    }
}

extension OfficeLocationReadDTO {
    func toShiftOption() -> ShiftStartOption? {
        guard
            let name = officeName, !name.isEmpty,
            let lat = latitude,
            let lng = longitude
        else { return nil }

    
        let safeId = id ?? identity

        return .office(id: safeId, name: name, lat: lat, lng: lng)
    }
}
