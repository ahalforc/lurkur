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

    @Test func authRedirectParsesTrailingSlashAndBareHost() {
        let withSlash = URL(string: "https://www.reddit.com/?state=abc-123&code=def-456")!
        let bareHost = URL(string: "https://reddit.com?state=abc-123&code=def-456")!
        #expect(AuthWebView.Coordinator.authRedirectCredentials(from: withSlash)?.code == "def-456")
        #expect(AuthWebView.Coordinator.authRedirectCredentials(from: bareHost)?.stateId == "abc-123")
    }

    @Test func authRedirectIgnoresUnrelatedRedditURLs() {
        let url = URL(string: "https://www.reddit.com/r/swift")!
        let result = AuthWebView.Coordinator.authRedirectCredentials(from: url)
        #expect(result == nil)
    }

    @Test func authRedirectIgnoresLoginPagesWithoutCode() {
        let url = URL(string: "https://www.reddit.com/login/?dest=https%3A%2F%2Fwww.reddit.com")!
        #expect(AuthWebView.Coordinator.authRedirectCredentials(from: url) == nil)
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

    @Test func mapsSubmissionSelfPost() {
        let data: [String: Any] = [
            "id": "abc",
            "title": "Hello",
            "author": "orka",
            "subreddit": "swift",
            "num_comments": 3,
            "score": 10,
            "created_utc": 1_700_000_000.0,
            "over_18": false,
            "pinned": false,
            "stickied": true,
            "url": "https://www.reddit.com/r/swift/comments/abc/hello/",
            "selftext": "**bold** text",
        ]

        let submission = RedditMapping.submission(from: data)
        #expect(submission?.id == "abc")
        #expect(submission?.title == "Hello")
        #expect(submission?.isStickied == true)
        #expect(submission?.selfText == "**bold** text")
        #expect(submission?.subreddit == "swift")
        #expect(submission?.linkURL == nil)
    }

    @Test func mapsExternalLinkOnly() {
        let data: [String: Any] = [
            "id": "xyz",
            "title": "Link",
            "author": "orka",
            "subreddit": "swift",
            "num_comments": 0,
            "score": 1,
            "created_utc": 1_700_000_000.0,
            "url": "https://example.com/article",
            "selftext": "",
        ]
        let submission = RedditMapping.submission(from: data)
        #expect(submission?.linkURL?.absoluteString == "https://example.com/article")
    }

    @Test func mapsCommentWithDeletedAuthor() {
        let data: [String: Any] = [
            "id": "c1",
            "author": "",
            "score": 1,
            "body": "gone",
            "edited": false,
            "is_submitter": false,
        ]
        let comment = RedditMapping.comment(from: data, fallbackID: "x")
        #expect(comment.displayAuthor == "Deleted")
        #expect(comment.body == "gone")
    }

    @Test func feedSortEndpointKeys() {
        #expect(FeedSort.hot.endpointSort == "hot")
        #expect(FeedSort.hot.endpointTimeWindow == nil)
        #expect(FeedSort.topDay.endpointSort == "top")
        #expect(FeedSort.topDay.endpointTimeWindow == "day")
        #expect(FeedSort.topAllTime.endpointTimeWindow == "all")
    }

    @Test func relativeTimeFormatsMinutes() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let earlier = now.addingTimeInterval(-120)
        #expect(RelativeTime.string(from: earlier, now: now) == "2m")
    }

    @Test @MainActor func preferencesHidesSubreddits() {
        let suite = "lurkur.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = PreferencesStore(defaults: defaults)
        #expect(store.isHidden("swift") == false)
        store.hideSubreddit("swift")
        #expect(store.isHidden("swift") == true)
        store.showSubreddit("swift")
        #expect(store.isHidden("swift") == false)
        store.setBrightness(.dark)
        store.setHideAutoModeratorComments(true)
        store.clearAll()
        #expect(store.brightness == .system)
        #expect(store.hideAutoModeratorComments == false)
    }
}
