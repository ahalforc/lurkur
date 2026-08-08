import Foundation
import Testing
@testable import lurkur_ios

struct lurkur_iosTests {
    @Test func authRedirectParsesStateAndCode() {
        let url = URL(string: "https://www.reddit.com?state=abc-123&code=def-456")!
        let result = AuthWebView.Coordinator.authRedirectCredentials(from: url)
        #expect(result?.stateId == "abc-123")
        #expect(result?.code == "def-456")
    }

    @Test func authRedirectIgnoresUnrelatedRedditURLs() {
        let url = URL(string: "https://www.reddit.com/r/swift")!
        let result = AuthWebView.Coordinator.authRedirectCredentials(from: url)
        #expect(result == nil)
    }

    @Test func authorizingStateBuildsRedditAuthURL() {
        let state = AuthState.authorizing(stateId: "test-state")
        let url = state.authorizationURL
        #expect(url != nil)

        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        let items = Dictionary(
            uniqueKeysWithValues: (components?.queryItems ?? []).compactMap { item in
                item.value.map { (item.name, $0) }
            }
        )

        #expect(components?.host == "old.reddit.com")
        #expect(items["client_id"] == AuthService.clientId)
        #expect(items["response_type"] == "code")
        #expect(items["state"] == "test-state")
        #expect(items["redirect_uri"] == AuthService.redirectURI)
        #expect(items["duration"] == "permanent")
        #expect(items["scope"] == "mysubreddits read subscribe")
    }
}
