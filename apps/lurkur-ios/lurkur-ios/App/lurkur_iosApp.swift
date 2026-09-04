import SwiftUI

@main
struct lurkur_iosApp: App {
    @State private var auth: AuthService
    @State private var preferences: PreferencesStore
    @State private var reddit: RedditClient

    init() {
        let auth = AuthService()
        _auth = State(initialValue: auth)
        _preferences = State(initialValue: PreferencesStore())
        _reddit = State(initialValue: RedditClient(auth: auth))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(auth)
                .environment(preferences)
                .environment(reddit)
                .preferredColorScheme(preferences.brightness.colorScheme)
        }
    }
}
