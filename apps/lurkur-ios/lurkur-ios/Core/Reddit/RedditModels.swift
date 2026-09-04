import Foundation

enum FeedSort: String, CaseIterable, Identifiable {
    case hot
    case topHour
    case topDay
    case topWeek
    case topMonth
    case topYear
    case topAllTime

    var id: String { rawValue }

    var label: String {
        switch self {
        case .hot: "Hot"
        case .topHour: "Top · Hour"
        case .topDay: "Top · Day"
        case .topWeek: "Top · Week"
        case .topMonth: "Top · Month"
        case .topYear: "Top · Year"
        case .topAllTime: "Top · All time"
        }
    }

    var endpointSort: String {
        switch self {
        case .hot: "hot"
        default: "top"
        }
    }

    var endpointTimeWindow: String? {
        switch self {
        case .hot: nil
        case .topHour: "hour"
        case .topDay: "day"
        case .topWeek: "week"
        case .topMonth: "month"
        case .topYear: "year"
        case .topAllTime: "all"
        }
    }
}

struct GalleryImage: Identifiable, Hashable, Sendable {
    let id: String
    let url: URL
    let width: Double
    let height: Double
}

struct VideoMedia: Hashable, Sendable {
    let url: URL
    let width: Double
    let height: Double

    var aspectRatio: Double {
        guard height > 0 else { return 16 / 9 }
        return width / height
    }
}

struct Submission: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let author: String
    let subreddit: String
    let commentCount: Int
    let score: Int
    let created: Date
    let isNsfw: Bool
    let isPinned: Bool
    let isStickied: Bool
    let linkURL: URL?
    let selfText: String?
    let gallery: [GalleryImage]
    let video: VideoMedia?
}

struct CommentNode: Identifiable, Hashable, Sendable {
    let id: String
    let author: String
    let score: Int
    let body: String
    let isEdited: Bool
    let isSubmitter: Bool
    let replies: [CommentNode]

    var displayAuthor: String {
        author.isEmpty ? "Deleted" : author
    }
}

struct Subscription: Identifiable, Hashable, Sendable {
    var id: String { displayName }
    let displayName: String
    let title: String
}

struct SubredditInfo: Hashable, Sendable {
    let bannerImageURL: URL?
}

enum FeedTarget: Hashable, Sendable {
    case home
    case popular
    case named(String)

    var subredditPath: String? {
        switch self {
        case .home: nil
        case .popular: "popular"
        case let .named(name): name
        }
    }

    var title: String {
        switch self {
        case .home: "Home"
        case .popular: "Popular"
        case let .named(name): "r/\(name)"
        }
    }

    var showsBanner: Bool {
        if case .named = self { return true }
        return false
    }
}
