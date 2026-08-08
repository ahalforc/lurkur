import SwiftUI

@main
struct lurkur_iosApp: App {
    @State private var auth = AuthService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(auth)
        }
    }
}
