import Foundation
import Security

/// Persists Reddit OAuth tokens in the Keychain.
struct AuthStorage {
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let expirationTimeKey = "expiration_time"

    var accessToken: String? {
        get { read(accessTokenKey) }
        nonmutating set { write(accessTokenKey, value: newValue) }
    }

    var refreshToken: String? {
        get { read(refreshTokenKey) }
        nonmutating set { write(refreshTokenKey, value: newValue) }
    }

    var expirationTime: Date? {
        get {
            guard let raw = read(expirationTimeKey),
                  let milliseconds = Int64(raw)
            else { return nil }
            return Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        }
        nonmutating set {
            guard let newValue else {
                write(expirationTimeKey, value: nil)
                return
            }
            let milliseconds = Int64(newValue.timeIntervalSince1970 * 1000)
            write(expirationTimeKey, value: String(milliseconds))
        }
    }

    func setExpirationTimeFromNow(seconds: Int) {
        expirationTime = Date().addingTimeInterval(TimeInterval(seconds))
    }

    func deleteAll() {
        accessToken = nil
        refreshToken = nil
        expirationTime = nil
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

    private func write(_ key: String, value: String?) {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        guard let value, let data = value.data(using: .utf8) else { return }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }
}
