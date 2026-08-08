import SwiftUI

struct ContentView: View {
    @Environment(AuthService.self) private var auth

    var body: some View {
        Group {
            switch auth.state {
            case .unauthorized, .checking, .authorizing:
                SignInView()
            case .authorized:
                SignedInPlaceholderView()
            }
        }
        .task {
            await auth.initialize()
        }
    }
}

/// Temporary stand-in until browsing is ported.
struct SignedInPlaceholderView: View {
    @Environment(AuthService.self) private var auth

    var body: some View {
        VStack(spacing: 16) {
            Text("Signed in")
                .font(.title)
            Button("Sign out", role: .destructive) {
                Task { await auth.logout() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .environment(AuthService())
}
