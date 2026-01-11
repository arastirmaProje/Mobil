//
//  FakeLocationManager.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim
import CoreLocation

final class FakeLocationManager: LocationManaging {

    var coordinateToReturn: CLLocationCoordinate2D?
    var errorToThrow: Error?

    func requestCoordinate() async throws -> CLLocationCoordinate2D {
        if let errorToThrow {
            throw errorToThrow
        }
        return coordinateToReturn
            ?? CLLocationCoordinate2D(latitude: 41.0, longitude: 29.0)
    }
}
