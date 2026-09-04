import SwiftUI
import WebKit

struct PostView: View {
    @Environment(RedditClient.self) private var reddit
    @Environment(PreferencesStore.self) private var preferences
    @Environment(\.dismiss) private var dismiss
    let submission: Submission

    @State private var store: PostStore?
    @State private var linkURL: URL?

    var body: some View {
        List {
            Section {
                PostSubmissionCard(submission: submission)

                if let link = submission.linkURL {
                    Button {
                        linkURL = link
                    } label: {
                        Label(link.absoluteString, systemImage: "link")
                            .lineLimit(2)
                    }
                }
            }

            Section("Comments") {
                if let store {
                    commentsSection(store)
                } else {
                    ProgressView()
                }
            }
        }
        .navigationTitle("Post")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Hide r/\(submission.subreddit)", role: .destructive) {
                        preferences.hideSubreddit(submission.subreddit)
                        dismiss()
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { linkURL != nil },
            set: { if !$0 { linkURL = nil } }
        )) {
            if let linkURL {
                NavigationStack {
                    InAppWebView(url: linkURL)
                        .ignoresSafeArea(edges: .bottom)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { self.linkURL = nil }
                            }
                        }
                        .navigationTitle("Link")
                        #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                }
            }
        }
        .task(id: submission.id) {
            let created = PostStore(submission: submission, reddit: reddit)
            store = created
            await created.load()
        }
    }

    @ViewBuilder
    private func commentsSection(_ store: PostStore) -> some View {
        switch store.phase {
        case .idle, .loading:
            ProgressView()
        case .failed:
            Text(store.errorMessage ?? "Failed to load comments")
            Button("Retry") { Task { await store.load() } }
        case .loaded:
            let visible = store.comments.filter { comment in
                !(preferences.hideAutoModeratorComments && comment.author == "AutoModerator")
            }
            if visible.isEmpty {
                Text("No comments")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(visible) { comment in
                    CommentRow(comment: comment, depth: 0, hideAutoMod: preferences.hideAutoModeratorComments)
                }
            }
        }
    }
}

struct CommentRow: View {
    let comment: CommentNode
    let depth: Int
    let hideAutoMod: Bool
    @State private var expanded = true

    var body: some View {
        DisclosureGroup(isExpanded: $expanded) {
            let replies = comment.replies.filter { reply in
                !(hideAutoMod && reply.author == "AutoModerator")
            }
            ForEach(replies) { reply in
                CommentRow(comment: reply, depth: depth + 1, hideAutoMod: hideAutoMod)
                    .padding(.leading, 8)
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(comment.displayAuthor)
                        .font(.subheadline.weight(.semibold))
                    Text("↑ \(comment.score)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if comment.isSubmitter {
                        Text("OP")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .background(.tint.opacity(0.2), in: Capsule())
                    }
                    if comment.isEdited {
                        Text("Edited")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                PostCommentBody(bodyText: comment.body)
            }
        }
    }
}

#if os(iOS)
struct InAppWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#elseif os(macOS)
struct InAppWebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
#endif
