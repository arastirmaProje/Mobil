//
//  OneShotLocationManager.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import CoreLocation

@MainActor
final class OneShotLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, LocationManaging{

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestCoordinate() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

        let st = manager.authorizationStatus
        if st == .denied || st == .restricted {
            throw NSError(domain: "location", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Konum izni kapalı. Ayarlardan izin verip tekrar dene."
            ])
        }

        return try await withCheckedThrowingContinuation { cont in
            continuation = cont
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let c = locations.first?.coordinate else { return }
        continuation?.resume(returning: c)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
