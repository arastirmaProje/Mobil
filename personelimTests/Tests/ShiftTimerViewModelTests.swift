//
//  ShiftTimerViewModelTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim
import CoreLocation

@MainActor
final class ShiftTimerViewModelTests: XCTestCase {

    private var useCase: MockCreateShiftUseCase!
    private var locationManager: FakeLocationManager!
    private var vm: ShiftTimerViewModel!

    override func setUp() {
        super.setUp()

        ShiftStore.shared.clear()

        useCase = MockCreateShiftUseCase()

        locationManager = FakeLocationManager()
        locationManager.coordinateToReturn =
            CLLocationCoordinate2D(latitude: 41.0, longitude: 29.0)

        vm = ShiftTimerViewModel(
            createShiftUseCase: useCase,
           // locationManager: locationManager,
            toleranceMeters: 150
        )
    }

    override func tearDown() {
        ShiftStore.shared.clear()
        vm = nil
        super.tearDown()
    }

    // MARK: - Start (Home)

    func test_start_home_success() async {
        vm.confirmStart(option: .home)

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(vm.isRunning)
        XCTAssertFalse(vm.isPaused)
        XCTAssertNil(vm.errorMessage)
        XCTAssertNotNil(ShiftStore.shared.load())
    }

    // MARK: - Pause / Resume

    func test_pause_and_resume_updatesPausedSeconds() async {
        vm.confirmStart(option: .home)
        try? await Task.sleep(nanoseconds: 200_000_000)

        vm.pause()
        XCTAssertTrue(vm.isPaused)

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        vm.resume()
        XCTAssertFalse(vm.isPaused)

        let state = ShiftStore.shared.load()
        XCTAssertNotNil(state)
        XCTAssertTrue(state!.pausedTotalSeconds >= 1)
    }

    // MARK: - Restore

    func test_restore_from_store_success() async {
        vm.confirmStart(option: .home)
        try? await Task.sleep(nanoseconds: 200_000_000)

        let savedState = ShiftStore.shared.load()
        XCTAssertNotNil(savedState)

        let restored = ShiftTimerViewModel(
            createShiftUseCase: useCase,
            toleranceMeters: 150
        )

        XCTAssertTrue(restored.isRunning)
        XCTAssertFalse(restored.isPaused)
        XCTAssertNil(restored.errorMessage)
        XCTAssertNotNil(ShiftStore.shared.load())
    }

    // MARK: - End Day

    func test_endDay_callsCreateShift() async {
        vm.confirmStart(option: .home)
        try? await Task.sleep(nanoseconds: 300_000_000)

        vm.endDay(businessId: "biz_1")
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertNotNil(useCase.executedBody)
        XCTAssertEqual(useCase.executedBody?.businessId, "biz_1")
        XCTAssertNil(ShiftStore.shared.load())
    }

    // MARK: - End without start

    func test_endDay_withoutStart_setsError() async {
        vm.endDay(businessId: "biz_1")
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(vm.errorMessage)
    }
}
