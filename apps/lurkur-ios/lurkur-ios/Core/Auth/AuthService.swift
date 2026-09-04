import Foundation
import Observation
import OSLog

enum AuthState: Equatable {
    case unauthorized
    case checking
    case authorizing(stateId: String)
    case authorized(accessToken: String)

    var accessToken: String? {
        if case let .authorized(token) = self { return token }
        return nil
    }

    var authorizationURL: URL? {
        guard case let .authorizing(stateId) = self else { return nil }
        var components = URLComponents(string: "https://old.reddit.com/api/v1/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: AuthService.clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "state", value: stateId),
            URLQueryItem(name: "redirect_uri", value: AuthService.redirectURI),
            URLQueryItem(name: "duration", value: "permanent"),
            URLQueryItem(name: "scope", value: "mysubreddits read subscribe"),
        ]
        return components.url
    }
}

@MainActor
@Observable
final class AuthService {
    static let clientId = Secrets.clientId
    static let redirectURI = "https://www.reddit.com"

    private(set) var state: AuthState = .unauthorized

    private let storage: AuthStorage
    private let session: URLSession

    init(storage: AuthStorage = AuthStorage(), session: URLSession = .shared) {
        self.storage = storage
        self.session = session
    }

    func initialize() async {
        state = .checking

        guard let accessToken = storage.accessToken(),
              let expirationTime = storage.expirationTime(),
              let refreshToken = storage.refreshToken()
        else {
            state = .unauthorized
            return
        }

        if expirationTime < Date() {
            LurkurLog.auth.info("Access token expired; refreshing")
            if let refreshed = await refreshAccessToken(refreshToken) {
                state = .authorized(accessToken: refreshed)
            } else {
                LurkurLog.auth.error("Token refresh failed; logging out")
                await logout()
            }
            return
        }

        state = .authorized(accessToken: accessToken)
    }

    /// Starts the Reddit web OAuth flow and returns the authorization URL.
    func startAuthorizingViaWeb() -> URL {
        let stateId = UUID().uuidString
        let next = AuthState.authorizing(stateId: stateId)
        state = next
        return next.authorizationURL!
    }

    /// Completes OAuth after the redirect provides `state` and `code`.
    func completeAuthorizingViaWeb(stateId: String, code: String) async {
        guard case let .authorizing(expected) = state, expected == stateId else { return }

        if let accessToken = await fetchAccessToken(stateId: stateId, code: code) {
            state = .authorized(accessToken: accessToken)
        } else {
            state = .unauthorized
        }
    }

    func logout() async {
        storage.deleteAll()
        state = .unauthorized
    }

    /// Returns to the signed-out UI without clearing stored tokens.
    /// Used when the user cancels the in-progress web OAuth sheet.
    func cancelAuthorizing() {
        guard case .authorizing = state else { return }
        state = .unauthorized
    }

    private func fetchAccessToken(stateId _: String, code: String) async -> String? {
        let body = [
            "grant_type=authorization_code",
            "code=\(code)",
            "redirect_uri=\(Self.redirectURI)",
        ].joined(separator: "&")

        return await exchangeToken(body: body, expectRefreshToken: true)
    }

    private func refreshAccessToken(_ refreshToken: String) async -> String? {
        let body = [
            "grant_type=refresh_token",
            "refresh_token=\(refreshToken)",
        ].joined(separator: "&")

        return await exchangeToken(body: body, expectRefreshToken: false)
    }

    private func exchangeToken(body: String, expectRefreshToken: Bool) async -> String? {
        guard let url = URL(string: "https://www.reddit.com/api/v1/access_token") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(body.utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(Self.basicAuthHeader)", forHTTPHeaderField: "Authorization")
        request.setValue("lurkur-ios/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                LurkurLog.auth.error("Token exchange failed with non-200 response")
                return nil
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let accessToken = json["access_token"] as? String,
                  let expiresIn = json["expires_in"] as? Int
            else {
                LurkurLog.auth.error("Token exchange response missing fields")
                return nil
            }

            guard storage.setAccessToken(accessToken),
                  storage.setExpirationTimeFromNow(seconds: expiresIn)
            else {
                LurkurLog.auth.error("Keychain write failed during token exchange")
                return nil
            }

            if expectRefreshToken {
                guard let refreshToken = json["refresh_token"] as? String,
                      storage.setRefreshToken(refreshToken)
                else {
                    LurkurLog.auth.error("Keychain refresh-token write failed")
                    return nil
                }
            }

            return accessToken
        } catch {
            LurkurLog.auth.error("Token exchange error: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private static var basicAuthHeader: String {
        Data("\(clientId):".utf8).base64EncodedString()
    }
}
