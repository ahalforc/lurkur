import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class PostStore {
    enum Phase {
        case idle
        case loading
        case loaded
        case failed
    }

    let submission: Submission
    private let reddit: RedditClient

    private(set) var phase: Phase = .idle
    private(set) var comments: [CommentNode] = []
    private(set) var errorMessage: String?

    init(submission: Submission, reddit: RedditClient) {
        self.submission = submission
        self.reddit = reddit
    }

    func load() async {
        phase = .loading
        errorMessage = nil
        do {
            comments = try await reddit.fetchComments(
                subreddit: submission.subreddit,
                submissionID: submission.id
            )
            phase = .loaded
            LurkurLog.post.info("Loaded \(self.comments.count) top-level comments")
        } catch {
            phase = .failed
            errorMessage = error.localizedDescription
            LurkurLog.post.error("Comments failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
