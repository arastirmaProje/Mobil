import Foundation

struct ShiftPauseStateDTO: Codable {

    let startedAtTs: TimeInterval
    let pausedTotalSeconds: Int
    let isPaused: Bool
    let pausedAtTs: TimeInterval?
    let option: StoredShiftOption

    private enum CodingKeys: String, CodingKey {
        case startedAtTs, pausedTotalSeconds, isPaused, pausedAtTs, option
        case startedAtIso, pausedAtIso
    }

    init(
        startedAtTs: TimeInterval,
        pausedTotalSeconds: Int,
        isPaused: Bool,
        pausedAtTs: TimeInterval?,
        option: StoredShiftOption
    ) {
        self.startedAtTs = startedAtTs
        self.pausedTotalSeconds = pausedTotalSeconds
        self.isPaused = isPaused
        self.pausedAtTs = pausedAtTs
        self.option = option
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        if let ts = try? c.decode(TimeInterval.self, forKey: .startedAtTs) {
            self.startedAtTs = ts
            self.pausedAtTs = try c.decodeIfPresent(TimeInterval.self, forKey: .pausedAtTs)
        } else {
            let startedIso = try c.decode(String.self, forKey: .startedAtIso)
            let startedDate =
                ISO8601DateFormatter().date(from: startedIso)
                ?? ISO8601DateFormatter().date(from: startedIso.replacingOccurrences(of: "Z", with: "+00:00"))
            self.startedAtTs = startedDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970

            if let pausedIso = try c.decodeIfPresent(String.self, forKey: .pausedAtIso) {
                let pausedDate =
                    ISO8601DateFormatter().date(from: pausedIso)
                    ?? ISO8601DateFormatter().date(from: pausedIso.replacingOccurrences(of: "Z", with: "+00:00"))
                self.pausedAtTs = pausedDate?.timeIntervalSince1970
            } else {
                self.pausedAtTs = nil
            }
        }

        self.pausedTotalSeconds = try c.decode(Int.self, forKey: .pausedTotalSeconds)
        self.isPaused = try c.decode(Bool.self, forKey: .isPaused)
        self.option = try c.decode(StoredShiftOption.self, forKey: .option)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(startedAtTs, forKey: .startedAtTs)
        try c.encode(pausedTotalSeconds, forKey: .pausedTotalSeconds)
        try c.encode(isPaused, forKey: .isPaused)
        try c.encodeIfPresent(pausedAtTs, forKey: .pausedAtTs)
        try c.encode(option, forKey: .option)
    }
}
