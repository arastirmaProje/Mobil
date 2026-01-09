//
//  ShiftTimerViewModel.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import Foundation
import CoreLocation

@MainActor
final class ShiftTimerViewModel: ObservableObject {

    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var elapsedText: String = "00:00:00"
    @Published var errorMessage: String?
    @Published var showLocationPicker: Bool = false

    private(set) var startOption: ShiftStartOption?
    private var startedAt: Date?
    private var pausedAt: Date?
    private var pausedTotalSeconds: Int = 0

    private var timer: Timer?

    private let createShiftUseCase: CreateShiftUseCaseProtocol
    private let locationManager = OneShotLocationManager()
    private let store = ShiftStore.shared

    private let toleranceMeters: Double

    init(
        createShiftUseCase: CreateShiftUseCaseProtocol = CreateShiftUseCase(
            repo: ShiftRepositoryImpl(network: NetworkManager())
        ),
        toleranceMeters: Double = 150
    ) {
        self.createShiftUseCase = createShiftUseCase
        self.toleranceMeters = toleranceMeters

        restoreIfNeeded()
    }

    // MARK: - Public

    func openStartSheet() {
        errorMessage = nil
        showLocationPicker = true
    }

    func confirmStart(option: ShiftStartOption) {
        Task { await startFlow(option: option) }
    }

    func pause() {
        guard isRunning, !isPaused else { return }
        isPaused = true
        pausedAt = Date()
        stopTimer()
        persist()
    }

    func resume() {
        guard isRunning, isPaused else { return }
        isPaused = false

        if let pausedAt {
            let add = Int(Date().timeIntervalSince(pausedAt))
            pausedTotalSeconds += max(0, add)
        }

        self.pausedAt = nil
        startTimer()
        persist()
    }

    func endDay(businessId: String) {
        Task { await endFlow(businessId: businessId) }
    }

    func resetLocal() {
        stopTimer()
        isRunning = false
        isPaused = false
        elapsedText = "00:00:00"

        startedAt = nil
        pausedAt = nil
        pausedTotalSeconds = 0
        startOption = nil

        store.clear()
    }

    // MARK: - Start

    private func startFlow(option: ShiftStartOption) async {
        errorMessage = nil

        print("SHIFT START FLOW")
        print("Option:", option)

        do {
            if option.isOffice {
                print("Office selected – validating location")

                let current = try await locationManager.requestCoordinate()
                print("Current location:",
                      current.latitude,
                      current.longitude)

                guard let target = option.coordinate else {
                    print("Target office coordinate is nil")
                    throw NSError(
                        domain: "shift",
                        code: 9,
                        userInfo: [NSLocalizedDescriptionKey: "Ofis koordinatı bulunamadı."]
                    )
                }

                print("Target office location:",
                      target.latitude,
                      target.longitude)

                let ok = LocationValidator.isWithinTolerance(
                    user: current,
                    target: target,
                    toleranceMeters: toleranceMeters
                )

                print("Distance OK?", ok, "| tolerance:", toleranceMeters, "m")

                guard ok else {
                    let msg = "Seçilen ofise yeterince yakın değilsin."
                    print("SHIFT START FAILED:", msg)
                    throw NSError(domain: "shift", code: 10, userInfo: [
                        NSLocalizedDescriptionKey: msg
                    ])
                }
            } else {
                print("Home selected – skipping location validation")
            }

            print("SHIFT START SUCCESS")

            startedAt = Date()
            startOption = option
            isRunning = true
            isPaused = false
            pausedAt = nil
            pausedTotalSeconds = 0

            startTimer()
            persist()

        } catch {
            print("SHIFT START ERROR:", error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }


    // MARK: - End

    private func endFlow(businessId: String) async {
        errorMessage = nil

        guard let startedAt else {
            errorMessage = "Mesai başlatılmadan gün sonlandırılamaz."
            return
        }

        do {
            if isPaused, let pausedAt {
                let add = Int(Date().timeIntervalSince(pausedAt))
                pausedTotalSeconds += max(0, add)
                self.pausedAt = nil
                isPaused = false
            }
            if let opt = startOption, opt.isOffice {
                let current = try await locationManager.requestCoordinate()
                guard let target = opt.coordinate else { return }

                let ok = LocationValidator.isWithinTolerance(
                    user: current,
                    target: target,
                    toleranceMeters: toleranceMeters
                )

                guard ok else {
                    throw NSError(domain: "shift", code: 11, userInfo: [
                        NSLocalizedDescriptionKey: "Mesaiyi aynı ofiste bitirmelisin."
                    ])
                }
            }

            let now = Date()
            let rawSeconds = Int(now.timeIntervalSince(startedAt))
            let workedSeconds = max(0, rawSeconds - pausedTotalSeconds)
            let endAt = startedAt.addingTimeInterval(TimeInterval(workedSeconds))

            let body = CreateShiftRequestDTO(
                businessId: businessId,
                startTime: ISODate.string(from: startedAt),
                endTime: ISODate.string(from: endAt)
            )

            try await createShiftUseCase.execute(body)

            resetLocal()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.updateElapsed()
            }
        }

        updateElapsed()
    }


    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateElapsed() {
        guard let startedAt else { return }

        let now = Date()
        let raw = Int(now.timeIntervalSince(startedAt))

        var pausedTotal = pausedTotalSeconds
        if isPaused, let pausedAt {
            pausedTotal += max(0, Int(now.timeIntervalSince(pausedAt)))
        }

        let worked = max(0, raw - pausedTotal)
        elapsedText = Self.format(seconds: worked)
    }

    private static func format(seconds: Int) -> String {
        String(format: "%02d:%02d:%02d", seconds/3600, (seconds%3600)/60, seconds%60)
    }

    // MARK: - Persist / Restore

    private func persist() {
        guard let startedAt, let startOption else { return }

        let state = ShiftPauseStateDTO(
            startedAtTs: startedAt.timeIntervalSince1970,
            pausedTotalSeconds: pausedTotalSeconds,
            isPaused: isPaused,
            pausedAtTs: pausedAt?.timeIntervalSince1970,
            option: StoredShiftOption.from(startOption)
        )
        store.save(state)
    }


    private func restoreIfNeeded() {
        guard let s = store.load() else { return }

        self.startedAt = Date(timeIntervalSince1970: s.startedAtTs)
        self.pausedTotalSeconds = s.pausedTotalSeconds
        self.isPaused = s.isPaused
        self.pausedAt = s.pausedAtTs.map { Date(timeIntervalSince1970: $0) }

        self.startOption = s.option.toDomain()
        self.isRunning = (self.startOption != nil)

        if isRunning && !isPaused {
            startTimer()
        } else {
            updateElapsed()
        }
    }

}
