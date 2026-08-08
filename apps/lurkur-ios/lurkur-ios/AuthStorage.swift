import Foundation
import Security

/// Persists Reddit OAuth tokens in the Keychain.
struct AuthStorage {
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let expirationTimeKey = "expiration_time"

    func accessToken() -> String? { read(accessTokenKey) }

    func refreshToken() -> String? { read(refreshTokenKey) }

    func expirationTime() -> Date? {
        guard let raw = read(expirationTimeKey),
              let milliseconds = Int64(raw)
        else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    @discardableResult
    func setAccessToken(_ token: String) -> Bool {
        write(accessTokenKey, value: token)
    }

    @discardableResult
    func setRefreshToken(_ token: String) -> Bool {
        write(refreshTokenKey, value: token)
    }

    @discardableResult
    func setExpirationTime(_ date: Date) -> Bool {
        let milliseconds = Int64(date.timeIntervalSince1970 * 1000)
        return write(expirationTimeKey, value: String(milliseconds))
    }

    @discardableResult
    func setExpirationTimeFromNow(seconds: Int) -> Bool {
        setExpirationTime(Date().addingTimeInterval(TimeInterval(seconds)))
    }

    func deleteAll() {
        delete(accessTokenKey)
        delete(refreshTokenKey)
        delete(expirationTimeKey)
    }

    private func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return nil }
        return value
    }

    @discardableResult
    private func write(_ key: String, value: String) -> Bool {
        delete(key)
        guard let data = value.data(using: .utf8) else { return false }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
    }

    private func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
