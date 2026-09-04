import OSLog

enum LurkurLog {
    static let auth = Logger(subsystem: "lurkur", category: "auth")
    static let reddit = Logger(subsystem: "lurkur", category: "reddit")
    static let feed = Logger(subsystem: "lurkur", category: "feed")
    static let post = Logger(subsystem: "lurkur", category: "post")
}
