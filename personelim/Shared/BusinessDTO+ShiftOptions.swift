//
//  BusinessDTO+ShiftOptions.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

extension BusinessDTO {
    func toShiftOfficeOptions() -> [ShiftStartOption] {

        // ✅ 1) Çoklu ofis varsa
        if let offices, !offices.isEmpty {
            let opts = offices.compactMap { $0.toShiftOption() }
            if !opts.isEmpty { return opts }
        }

        // ✅ 2) Fallback: Business'ın tek lokasyonu
        let title = (locationName?.isEmpty == false ? locationName! : name)
        return [
            .office(id: id, name: title, lat: latitude, lng: longitude)
        ]
    }
}
