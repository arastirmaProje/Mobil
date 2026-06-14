import Foundation

final class TokenStore {

    static let shared = TokenStore()

    private init() {
        cachedToken = UserDefaults.standard.string(forKey: tokenKey)
        cachedBusinessId = UserDefaults.standard.string(forKey: selectedBusinessIdKey)
        rememberMe = UserDefaults.standard.bool(forKey: rememberMeKey)
    }

    private let tokenKey = "auth_token"
    private let selectedBusinessIdKey = "selected_business_id"
    private let rememberMeKey = "remember_me"

    private var cachedToken: String?
    private var cachedBusinessId: String?
    private var rememberMe: Bool

    var token: String? {
        cachedToken
    }

    var isRememberMeEnabled: Bool {
        rememberMe
    }

    func save(_ token: String, rememberMe: Bool) {
        self.rememberMe = rememberMe
        cachedToken = token

        UserDefaults.standard.set(rememberMe, forKey: rememberMeKey)

        if rememberMe {
            UserDefaults.standard.set(token, forKey: tokenKey)
        } else {
            UserDefaults.standard.removeObject(forKey: tokenKey)
        }
    }

    var selectedBusinessId: String? {
        get { cachedBusinessId }
        set {
            cachedBusinessId = newValue

            if rememberMe, let v = newValue {
                UserDefaults.standard.set(v, forKey: selectedBusinessIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: selectedBusinessIdKey)
            }
        }
    }

    func clear() {
        cachedToken = nil
        cachedBusinessId = nil
        rememberMe = false

        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: selectedBusinessIdKey)
        UserDefaults.standard.removeObject(forKey: rememberMeKey)
    }

    func clearPersistentSessionOnly() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: selectedBusinessIdKey)
        UserDefaults.standard.removeObject(forKey: rememberMeKey)
    }

    func hasValidToken() -> Bool {
        cachedToken != nil
    }

    func hasPersistentLogin() -> Bool {
        rememberMe && cachedToken != nil
    }
}
