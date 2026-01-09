import Foundation

final class ShiftStore {

    static let shared = ShiftStore()
    private init() {}

    private let key = "shift_pause_state_data"

    func save(_ state: ShiftPauseStateDTO) {
        do {
            let data = try JSONEncoder().encode(state)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("ShiftStore save error:", error)
        }
    }

    func load() -> ShiftPauseStateDTO? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(ShiftPauseStateDTO.self, from: data)
        } catch {
            print("ShiftStore load/decode error:", error)
            return nil
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
