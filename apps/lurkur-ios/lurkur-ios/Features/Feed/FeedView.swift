import SwiftUI

struct FeedView: View {
    @Environment(RedditClient.self) private var reddit
    @Environment(PreferencesStore.self) private var preferences
    let target: FeedTarget

    @State private var store: FeedStore?

    var body: some View {
        Group {
            if let store {
                feedBody(store)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(target.title)
        .task(id: target) {
            let created = FeedStore(target: target, reddit: reddit, preferences: preferences)
            store = created
            await created.load()
        }
    }

    @ViewBuilder
    private func feedBody(_ store: FeedStore) -> some View {
        switch store.phase {
        case .idle, .loading:
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            ContentUnavailableView {
                Label("Couldn’t load feed", systemImage: "exclamationmark.triangle")
            } description: {
                Text(store.errorMessage ?? "Try again.")
            } actions: {
                Button("Retry") {
                    Task { await store.load() }
                }
            }
        case .loaded:
            List {
                ForEach(store.visibleSubmissions) { submission in
                    NavigationLink(value: submission) {
                        FeedSubmissionCard(submission: submission)
                    }
                    .contextMenu {
                        Button("Hide r/\(submission.subreddit)", role: .destructive) {
                            preferences.hideSubreddit(submission.subreddit)
                        }
                    }
                    .onAppear {
                        if submission.id == store.visibleSubmissions.last?.id {
                            Task { await store.loadMore() }
                        }
                    }
                }

                if store.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if store.loadMoreFailed {
                    Button("Retry loading more") {
                        Task { await store.loadMore() }
                    }
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .top, spacing: 0) {
                if let bannerURL = store.bannerURL {
                    AsyncImage(url: bannerURL) { phase in
                        switch phase {
                        case let .success(image):
                            image.resizable().scaledToFill()
                        default:
                            Color.clear
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 96)
                    .clipped()
                }
            }
            .refreshable { await store.load() }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(FeedSort.allCases) { option in
                            Button(option.label) {
                                Task { await store.load(sort: option) }
                            }
                        }
                    } label: {
                        Label(store.sort.label, systemImage: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}
