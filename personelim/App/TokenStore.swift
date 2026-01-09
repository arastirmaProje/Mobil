import Foundation

final class TokenStore {

    static let shared = TokenStore()
    private init() {
        cachedToken = UserDefaults.standard.string(forKey: tokenKey)
        cachedBusinessId = UserDefaults.standard.string(forKey: selectedBusinessIdKey)
    }

    private let tokenKey = "auth_token"
    private let selectedBusinessIdKey = "selected_business_id"

    // MARK: - In-memory cache
    private var cachedToken: String?
    private var cachedBusinessId: String?

    // MARK: - Token
    var token: String? {
        cachedToken
    }

    func save(_ token: String) {
        cachedToken = token
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    // MARK: - Business
    var selectedBusinessId: String? {
        get { cachedBusinessId }
        set {
            cachedBusinessId = newValue
            if let v = newValue {
                UserDefaults.standard.set(v, forKey: selectedBusinessIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: selectedBusinessIdKey)
            }
        }
    }

    // MARK: - Clear
    func clear() {
        cachedToken = nil
        cachedBusinessId = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: selectedBusinessIdKey)
    }

    func hasValidToken() -> Bool {
        cachedToken != nil
    }
}
