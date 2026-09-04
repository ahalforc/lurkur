import SwiftUI

struct BrowseView: View {
    @Environment(RedditClient.self) private var reddit
    @State private var store: BrowseStore?
    @State private var goToName = ""

    var body: some View {
        Group {
            if let store {
                content(store)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Browse")
        .task {
            let created = BrowseStore(reddit: reddit)
            store = created
            await created.load()
        }
    }

    @ViewBuilder
    private func content(_ store: BrowseStore) -> some View {
        List {
            Section("Go to a subreddit") {
                HStack {
                    TextField("subreddit", text: $goToName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    NavigationLink(value: FeedTarget.named(normalizedGoTo)) {
                        Text("Go")
                    }
                    .disabled(normalizedGoTo.isEmpty)
                }
            }

            Section("Subscriptions") {
                switch store.phase {
                case .idle, .loading:
                    ProgressView()
                case .failed:
                    Text(store.errorMessage ?? "Failed to load")
                    Button("Retry") { Task { await store.load() } }
                case .loaded:
                    if store.subscriptions.isEmpty {
                        Text("No subscriptions")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.subscriptions) { subscription in
                            NavigationLink(value: FeedTarget.named(subscription.displayName)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("r/\(subscription.displayName)")
                                    if !subscription.title.isEmpty {
                                        Text(subscription.title)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .refreshable { await store.load() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await store.load() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
    }

    private var normalizedGoTo: String {
        goToName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "r/", with: "", options: [.anchored, .caseInsensitive])
    }
}
