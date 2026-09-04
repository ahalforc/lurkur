import Foundation

enum RedditJSON {
    static func string(_ value: Any?) -> String? {
        value as? String
    }

    static func int(_ value: Any?) -> Int? {
        if let i = value as? Int { return i }
        if let d = value as? Double { return Int(d) }
        if let n = value as? NSNumber { return n.intValue }
        return nil
    }

    static func double(_ value: Any?) -> Double? {
        if let d = value as? Double { return d }
        if let i = value as? Int { return Double(i) }
        if let n = value as? NSNumber { return n.doubleValue }
        return nil
    }

    static func bool(_ value: Any?) -> Bool {
        if let b = value as? Bool { return b }
        if let n = value as? NSNumber { return n.boolValue }
        return false
    }

    static func dateFromUTC(_ value: Any?) -> Date? {
        guard let seconds = double(value) else { return nil }
        return Date(timeIntervalSince1970: seconds)
    }

    static func dict(_ value: Any?) -> [String: Any]? {
        value as? [String: Any]
    }

    static func array(_ value: Any?) -> [Any]? {
        value as? [Any]
    }
}

enum RedditMapping {
    static func submission(from data: [String: Any]) -> Submission? {
        guard let id = RedditJSON.string(data["id"]),
              let title = RedditJSON.string(data["title"]),
              let author = RedditJSON.string(data["author"]),
              let subreddit = RedditJSON.string(data["subreddit"]),
              let created = RedditJSON.dateFromUTC(data["created_utc"])
        else { return nil }

        let selfText: String? = {
            guard let text = RedditJSON.string(data["selftext"]), !text.isEmpty else { return nil }
            return text
        }()

        let video = videoMedia(from: data)
        let gallery = video == nil ? galleryImages(from: data) : []

        return Submission(
            id: id,
            title: title,
            author: author,
            subreddit: subreddit,
            commentCount: RedditJSON.int(data["num_comments"]) ?? 0,
            score: RedditJSON.int(data["score"]) ?? 0,
            created: created,
            isNsfw: RedditJSON.bool(data["over_18"]),
            isPinned: RedditJSON.bool(data["pinned"]),
            isStickied: RedditJSON.bool(data["stickied"]),
            linkURL: externalLinkURL(from: data),
            selfText: selfText,
            gallery: gallery,
            video: video
        )
    }

    static func comment(from data: [String: Any], fallbackID: String) -> CommentNode {
        let author = RedditJSON.string(data["author"]) ?? ""
        let body = RedditJSON.string(data["body"]) ?? ""
        let id = RedditJSON.string(data["id"]) ?? fallbackID

        let editedValue = data["edited"]
        let isEdited: Bool = {
            if let b = editedValue as? Bool { return b }
            if editedValue is NSNumber { return true }
            return false
        }()

        var replies: [CommentNode] = []
        if let repliesObj = RedditJSON.dict(data["replies"]),
           let replyData = RedditJSON.dict(repliesObj["data"]),
           let children = RedditJSON.array(replyData["children"])
        {
            for (index, child) in children.enumerated() {
                guard let childDict = RedditJSON.dict(child),
                      RedditJSON.string(childDict["kind"]) == "t1",
                      let inner = RedditJSON.dict(childDict["data"])
                else { continue }
                replies.append(comment(from: inner, fallbackID: "\(id)-\(index)"))
            }
        }

        return CommentNode(
            id: id,
            author: author,
            score: RedditJSON.int(data["score"]) ?? 0,
            body: body,
            isEdited: isEdited,
            isSubmitter: RedditJSON.bool(data["is_submitter"]),
            replies: replies
        )
    }

    static func subscription(from data: [String: Any]) -> Subscription? {
        guard let displayName = RedditJSON.string(data["display_name"]), !displayName.isEmpty
        else { return nil }
        return Subscription(
            displayName: displayName,
            title: RedditJSON.string(data["title"]) ?? ""
        )
    }

    static func subredditInfo(from root: [String: Any]) -> SubredditInfo {
        let data = RedditJSON.dict(root["data"]) ?? root
        let banner = RedditJSON.string(data["mobile_banner_image"]).flatMap(URL.init(string:))
        return SubredditInfo(bannerImageURL: banner)
    }

    private static func externalLinkURL(from data: [String: Any]) -> URL? {
        guard let raw = RedditJSON.string(data["url"]), !raw.isEmpty,
              let url = URL(string: raw),
              let host = url.host?.lowercased()
        else { return nil }

        let isRedditHost =
            host == "reddit.com"
            || host.hasSuffix(".reddit.com")
            || host == "redd.it"
            || host.hasSuffix(".redd.it")
        if isRedditHost { return nil }
        return url
    }

    private static func galleryImages(from data: [String: Any]) -> [GalleryImage] {
        var images: [GalleryImage] = []

        if let preview = RedditJSON.dict(data["preview"]),
           let previewImages = RedditJSON.array(preview["images"])
        {
            for (index, entry) in previewImages.enumerated() {
                guard let imageDict = RedditJSON.dict(entry) else { continue }
                if let variants = RedditJSON.dict(imageDict["variants"]),
                   let gif = RedditJSON.dict(variants["gif"]),
                   let source = RedditJSON.dict(gif["source"]),
                   let mapped = galleryImage(from: source, id: "preview-gif-\(index)")
                {
                    images.append(mapped)
                } else if let source = RedditJSON.dict(imageDict["source"]),
                          let mapped = galleryImage(from: source, id: "preview-\(index)")
                {
                    images.append(mapped)
                }
            }
        }

        if let metadata = RedditJSON.dict(data["media_metadata"]) {
            for (key, value) in metadata {
                guard let entry = RedditJSON.dict(value) else { continue }
                let kind = RedditJSON.string(entry["e"])
                let status = RedditJSON.dict(entry["s"])
                let id = RedditJSON.string(entry["id"]) ?? key
                if kind == "Image", let status,
                   let urlString = RedditJSON.string(status["u"]),
                   let url = URL(string: urlString.replacingOccurrences(of: "&amp;", with: "&")),
                   let width = RedditJSON.double(status["x"]),
                   let height = RedditJSON.double(status["y"])
                {
                    images.append(GalleryImage(id: id, url: url, width: width, height: height))
                } else if kind == "AnimatedImage", let status,
                          let urlString = RedditJSON.string(status["gif"]),
                          let url = URL(string: urlString.replacingOccurrences(of: "&amp;", with: "&")),
                          let width = RedditJSON.double(status["x"]),
                          let height = RedditJSON.double(status["y"])
                {
                    images.append(GalleryImage(id: id, url: url, width: width, height: height))
                }
            }
        }

        if let galleryData = RedditJSON.dict(data["gallery_data"]),
           let items = RedditJSON.array(galleryData["items"])
        {
            var ordered: [GalleryImage] = []
            for item in items {
                guard let itemDict = RedditJSON.dict(item),
                      let mediaID = RedditJSON.string(itemDict["media_id"]),
                      let match = images.first(where: { $0.id == mediaID })
                else { continue }
                ordered.append(match)
            }
            if !ordered.isEmpty { return ordered }
        }

        return images
    }

    private static func galleryImage(from source: [String: Any], id: String) -> GalleryImage? {
        guard let urlString = RedditJSON.string(source["url"]),
              let url = URL(string: urlString.replacingOccurrences(of: "&amp;", with: "&")),
              let width = RedditJSON.double(source["width"]),
              let height = RedditJSON.double(source["height"])
        else { return nil }
        return GalleryImage(id: id, url: url, width: width, height: height)
    }

    private static func videoMedia(from data: [String: Any]) -> VideoMedia? {
        if let secure = RedditJSON.dict(data["secure_media"]),
           let redditVideo = RedditJSON.dict(secure["reddit_video"]),
           let urlString = RedditJSON.string(redditVideo["hls_url"]),
           let url = URL(string: urlString),
           let width = RedditJSON.double(redditVideo["width"]),
           let height = RedditJSON.double(redditVideo["height"])
        {
            return VideoMedia(url: url, width: width, height: height)
        }

        if let preview = RedditJSON.dict(data["preview"]),
           let redditVideo = RedditJSON.dict(preview["reddit_video_preview"]),
           let urlString = RedditJSON.string(redditVideo["fallback_url"]),
           let url = URL(string: urlString),
           let width = RedditJSON.double(redditVideo["width"]),
           let height = RedditJSON.double(redditVideo["height"])
        {
            return VideoMedia(url: url, width: width, height: height)
        }

        return nil
    }
}
