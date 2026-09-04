import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    FeedView(target: .home)
                        .navigationDestination(for: Submission.self) { submission in
                            PostView(submission: submission)
                        }
                }
            }

            Tab("Popular", systemImage: "flame") {
                NavigationStack {
                    FeedView(target: .popular)
                        .navigationDestination(for: Submission.self) { submission in
                            PostView(submission: submission)
                        }
                }
            }

            Tab("Browse", systemImage: "list.bullet") {
                NavigationStack {
                    BrowseView()
                        .navigationDestination(for: FeedTarget.self) { target in
                            FeedView(target: target)
                                .navigationDestination(for: Submission.self) { submission in
                                    PostView(submission: submission)
                                }
                        }
                }
            }

            Tab("Settings", systemImage: "gearshape") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        #if os(iOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
    }
}
