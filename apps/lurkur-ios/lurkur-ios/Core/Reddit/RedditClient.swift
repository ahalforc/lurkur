import Foundation
import Observation
import OSLog

enum RedditClientError: Error, LocalizedError {
    case unauthorized
    case badStatus(Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case .unauthorized: "Not signed in."
        case let .badStatus(code): "Reddit returned HTTP \(code)."
        case .decoding: "Could not read Reddit’s response."
        }
    }
}

@MainActor
@Observable
final class RedditClient {
    private let auth: AuthService
    private let session: URLSession
    private let baseURL = URL(string: "https://oauth.reddit.com")!

    init(auth: AuthService, session: URLSession = .shared) {
        self.auth = auth
        self.session = session
    }

    func fetchSubmissions(
        target: FeedTarget,
        sort: FeedSort,
        after: String?,
        count: Int?
    ) async throws -> (after: String, submissions: [Submission]) {
        var components = URLComponents(
            url: baseURL.appending(path: pathForSubmissions(target: target, sort: sort)),
            resolvingAgainstBaseURL: false
        )!
        var items = [URLQueryItem(name: "raw_json", value: "1")]
        if let after { items.append(URLQueryItem(name: "after", value: after)) }
        if let count { items.append(URLQueryItem(name: "count", value: String(count))) }
        if let t = sort.endpointTimeWindow {
            items.append(URLQueryItem(name: "t", value: t))
        }
        components.queryItems = items

        let json = try await getJSON(components.url!)
        guard let root = RedditJSON.dict(json),
              let data = RedditJSON.dict(root["data"]),
              let children = RedditJSON.array(data["children"])
        else { throw RedditClientError.decoding }

        let afterToken = RedditJSON.string(data["after"]) ?? ""
        var submissions: [Submission] = []
        for child in children {
            guard let childDict = RedditJSON.dict(child),
                  let inner = RedditJSON.dict(childDict["data"]),
                  let submission = RedditMapping.submission(from: inner)
            else { continue }
            submissions.append(submission)
        }
        return (afterToken, submissions)
    }

    func fetchSubredditInfo(named name: String) async throws -> SubredditInfo {
        var components = URLComponents(
            url: baseURL.appending(path: "/r/\(name)/about"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "raw_json", value: "1")]
        let json = try await getJSON(components.url!)
        guard let root = RedditJSON.dict(json) else { throw RedditClientError.decoding }
        return RedditMapping.subredditInfo(from: root)
    }

    func fetchSubscriptions() async throws -> [Subscription] {
        var components = URLComponents(
            url: baseURL.appending(path: "/subreddits/mine/subscriber"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "raw_json", value: "1"),
            URLQueryItem(name: "limit", value: "100"),
        ]
        let json = try await getJSON(components.url!)
        guard let root = RedditJSON.dict(json),
              let data = RedditJSON.dict(root["data"]),
              let children = RedditJSON.array(data["children"])
        else { throw RedditClientError.decoding }

        var result: [Subscription] = []
        for child in children {
            guard let childDict = RedditJSON.dict(child),
                  let inner = RedditJSON.dict(childDict["data"]),
                  let sub = RedditMapping.subscription(from: inner)
            else { continue }
            result.append(sub)
        }
        return result.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    func fetchComments(subreddit: String, submissionID: String) async throws -> [CommentNode] {
        var components = URLComponents(
            url: baseURL.appending(path: "/r/\(subreddit)/comments/\(submissionID)"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [URLQueryItem(name: "raw_json", value: "1")]
        let json = try await getJSON(components.url!)
        guard let entries = RedditJSON.array(json) else { throw RedditClientError.decoding }

        var comments: [CommentNode] = []
        for entry in entries {
            guard let entryDict = RedditJSON.dict(entry),
                  let data = RedditJSON.dict(entryDict["data"]),
                  let children = RedditJSON.array(data["children"])
            else { continue }
            for (index, child) in children.enumerated() {
                guard let childDict = RedditJSON.dict(child),
                      RedditJSON.string(childDict["kind"]) == "t1",
                      let inner = RedditJSON.dict(childDict["data"])
                else { continue }
                comments.append(RedditMapping.comment(from: inner, fallbackID: "root-\(index)"))
            }
        }
        return comments
    }

    private func pathForSubmissions(target: FeedTarget, sort: FeedSort) -> String {
        if let name = target.subredditPath {
            return "/r/\(name)/\(sort.endpointSort)"
        }
        return "/\(sort.endpointSort)"
    }

    private func getJSON(_ url: URL) async throws -> Any {
        guard let token = auth.state.accessToken else {
            LurkurLog.reddit.error("Request without access token")
            throw RedditClientError.unauthorized
        }

        var request = URLRequest(url: url)
        request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("lurkur-ios/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw RedditClientError.badStatus(-1)
            }
            guard http.statusCode == 200 else {
                LurkurLog.reddit.error("HTTP \(http.statusCode) for \(url.absoluteString, privacy: .public)")
                throw RedditClientError.badStatus(http.statusCode)
            }
            return try JSONSerialization.jsonObject(with: data)
        } catch let error as RedditClientError {
            throw error
        } catch {
            LurkurLog.reddit.error("Network failure: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
}
