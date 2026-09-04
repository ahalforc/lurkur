import Foundation
import Observation

@MainActor
@Observable
final class BrowseStore {
    enum Phase {
        case idle
        case loading
        case loaded
        case failed
    }

    private let reddit: RedditClient

    private(set) var phase: Phase = .idle
    private(set) var subscriptions: [Subscription] = []
    private(set) var errorMessage: String?

    init(reddit: RedditClient) {
        self.reddit = reddit
    }

    func load() async {
        phase = .loading
        errorMessage = nil
        do {
            subscriptions = try await reddit.fetchSubscriptions()
            phase = .loaded
        } catch {
            phase = .failed
            errorMessage = error.localizedDescription
        }
    }
}
