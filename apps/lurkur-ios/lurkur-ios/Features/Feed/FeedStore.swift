import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class FeedStore {
    enum Phase {
        case idle
        case loading
        case loaded
        case failed
    }

    let target: FeedTarget
    private let reddit: RedditClient
    private let preferences: PreferencesStore

    private(set) var phase: Phase = .idle
    private(set) var sort: FeedSort = .hot
    private(set) var submissions: [Submission] = []
    private(set) var bannerURL: URL?
    private(set) var after: String = ""
    private(set) var isLoadingMore = false
    private(set) var loadMoreFailed = false
    private(set) var errorMessage: String?

    init(target: FeedTarget, reddit: RedditClient, preferences: PreferencesStore) {
        self.target = target
        self.reddit = reddit
        self.preferences = preferences
    }

    var visibleSubmissions: [Submission] {
        submissions.filter { !preferences.isHidden($0.subreddit) }
    }

    func load(sort: FeedSort? = nil) async {
        if let sort { self.sort = sort }
        phase = .loading
        errorMessage = nil
        loadMoreFailed = false
        do {
            if target.showsBanner, let name = target.subredditPath {
                if let info = try? await reddit.fetchSubredditInfo(named: name) {
                    bannerURL = info.bannerImageURL
                }
            } else {
                bannerURL = nil
            }
            let page = try await reddit.fetchSubmissions(
                target: target,
                sort: self.sort,
                after: nil,
                count: nil
            )
            after = page.after
            submissions = page.submissions
            phase = .loaded
            LurkurLog.feed.info("Loaded \(page.submissions.count) submissions for \(self.target.title, privacy: .public)")
        } catch {
            phase = .failed
            errorMessage = error.localizedDescription
            LurkurLog.feed.error("Feed load failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func loadMore() async {
        guard phase == .loaded, !isLoadingMore, !after.isEmpty else { return }
        isLoadingMore = true
        loadMoreFailed = false
        do {
            let page = try await reddit.fetchSubmissions(
                target: target,
                sort: sort,
                after: after,
                count: submissions.count
            )
            after = page.after
            let existing = Set(submissions.map(\.id))
            submissions.append(contentsOf: page.submissions.filter { !existing.contains($0.id) })
            isLoadingMore = false
        } catch {
            isLoadingMore = false
            loadMoreFailed = true
            LurkurLog.feed.error("Load more failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
