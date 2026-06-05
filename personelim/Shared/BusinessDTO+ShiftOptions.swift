//
//  BusinessDTO+ShiftOptions.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation

extension BusinessDTO {
    func toShiftOfficeOptions() -> [ShiftStartOption] {

      
        if let offices, !offices.isEmpty {
            let opts = offices.compactMap { $0.toShiftOption() }
            if !opts.isEmpty { return opts }
        }

  
        let title = (locationName?.isEmpty == false ? locationName! : name)
        return [
            .office(id: id, name: title, lat: latitude, lng: longitude)
        ]
    }
}
