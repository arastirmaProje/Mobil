//
//  ShiftStartOption.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation
import CoreLocation

enum ShiftStartOption: Identifiable, Equatable, Hashable {
    case home
    case office(id: String, name: String, lat: Double, lng: Double)

    var id: String {
        switch self {
        case .home: return "home"
        case .office(let id, _, _, _): return "office-\(id)"
        }
    }

    var title: String {
        switch self {
        case .home: return "Ev"
        case .office(_, let name, _, _): return name
        }
    }

    var isOffice: Bool {
        if case .office = self { return true }
        return false
    }

    var coordinate: CLLocationCoordinate2D? {
        switch self {
        case .home: return nil
        case .office(_, _, let lat, let lng):
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }
}
