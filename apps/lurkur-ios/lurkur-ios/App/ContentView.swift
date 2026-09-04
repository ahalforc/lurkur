import SwiftUI

struct ContentView: View {
    @Environment(AuthService.self) private var auth

    var body: some View {
        Group {
            switch auth.state {
            case .unauthorized, .checking, .authorizing:
                SignInView()
            case .authorized:
                RootTabView()
            }
        }
        .task {
            await auth.initialize()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthService())
}
