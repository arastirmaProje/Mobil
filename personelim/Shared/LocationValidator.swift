//
//  LocationValidator.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import CoreLocation

enum LocationValidator {
    static func isWithinTolerance(
        user: CLLocationCoordinate2D,
        target: CLLocationCoordinate2D,
        toleranceMeters: Double
    ) -> Bool {
        let u = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let t = CLLocation(latitude: target.latitude, longitude: target.longitude)
        return u.distance(from: t) <= toleranceMeters
    }
}
