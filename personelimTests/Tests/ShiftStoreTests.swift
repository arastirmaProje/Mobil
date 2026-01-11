//
//  ShiftStoreTests.swift
//  personelim
//
//  Created by Tuğberk Acabey on 11.01.2026.
//

import XCTest
@testable import personelim

final class ShiftStoreTests: XCTestCase {

    private let store = ShiftStore.shared
    private let testKey = "shift_pause_state_data"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: testKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: testKey)
        super.tearDown()
    }

    // MARK: - Save & Load

    func test_saveAndLoad_state_success() {
        let option = StoredShiftOption(
            kind: .home,
            id: nil,
            name: nil,
            lat: nil,
            lng: nil
        )

        let state = ShiftPauseStateDTO(
            startedAtTs: 1_700_000_000,
            pausedTotalSeconds: 120,
            isPaused: true,
            pausedAtTs: 1_700_000_060,
            option: option
        )

        store.save(state)
        let loaded = store.load()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.startedAtTs, state.startedAtTs)
        XCTAssertEqual(loaded?.pausedTotalSeconds, 120)
        XCTAssertEqual(loaded?.isPaused, true)
        XCTAssertEqual(loaded?.pausedAtTs, state.pausedAtTs)
        XCTAssertEqual(loaded?.option, option)
    }

    // MARK: - Clear

    func test_clear_removesStoredState() {
        let option = StoredShiftOption(
            kind: .office,
            id: "office_1",
            name: "Merkez Ofis",
            lat: 41.015,
            lng: 28.979
        )

        let state = ShiftPauseStateDTO(
            startedAtTs: 1_700_000_000,
            pausedTotalSeconds: 0,
            isPaused: false,
            pausedAtTs: nil,
            option: option
        )

        store.save(state)
        XCTAssertNotNil(store.load())

        store.clear()
        XCTAssertNil(store.load())
    }

    // MARK: - Load when empty

    func test_load_whenNoData_returnsNil() {
        XCTAssertNil(store.load())
    }

    // MARK: - Legacy ISO Decode

    func test_decode_legacyISOFormat_success() {
        let json = """
        {
            "startedAtIso": "2026-01-01T08:00:00Z",
            "pausedAtIso": "2026-01-01T09:00:00Z",
            "pausedTotalSeconds": 600,
            "isPaused": true,
            "option": {
                "kind": "home",
                "id": null,
                "name": null,
                "lat": null,
                "lng": null
            }
        }
        """.data(using: .utf8)!

        UserDefaults.standard.set(json, forKey: testKey)

        let loaded = store.load()

        XCTAssertNotNil(loaded)
        XCTAssertTrue(loaded!.startedAtTs > 0)
        XCTAssertTrue(loaded!.pausedAtTs! > loaded!.startedAtTs)
        XCTAssertEqual(loaded!.pausedTotalSeconds, 600)
        XCTAssertEqual(loaded!.isPaused, true)
        XCTAssertEqual(loaded!.option.kind, .home)
    }
}
