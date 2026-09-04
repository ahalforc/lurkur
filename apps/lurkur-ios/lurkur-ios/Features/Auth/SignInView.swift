import SwiftUI

struct SignInView: View {
    @Environment(AuthService.self) private var auth
    @State private var authURL: URL?
    @State private var isCompleting = false
    /// Captured when the web view intercepts OAuth credentials so sheet dismiss
    /// can finish the exchange without treating it as a user cancel.
    @State private var pendingCredentials: (stateId: String, code: String)?

    var body: some View {
        VStack(spacing: 16) {
            Text("lurkur")
                .font(.largeTitle.bold())

            Text("Reddit, but simpler.")
                .font(.title3)
                .foregroundStyle(.secondary)

            if auth.state == .checking || isCompleting {
                ProgressView()
                    .padding(.top, 8)
            } else {
                Button("Sign in") {
                    authURL = auth.startAuthorizingViaWeb()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(
            isPresented: Binding(
                get: { authURL != nil },
                set: { if !$0 { authURL = nil } }
            ),
            onDismiss: handleAuthSheetDismiss
        ) {
            if let url = authURL {
                NavigationStack {
                    AuthWebView(url: url) { stateId, code in
                        pendingCredentials = (stateId, code)
                        authURL = nil
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                authURL = nil
                            }
                        }
                    }
                    .navigationTitle("Sign in")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                }
                #if os(macOS)
                .frame(minWidth: 480, minHeight: 640)
                #endif
            }
        }
    }

    /// Mirrors Flutter: close the web sheet first, then exchange the code while
    /// still in `.authorizing` — never call `cancelAuthorizing` on success.
    private func handleAuthSheetDismiss() {
        if let pendingCredentials {
            self.pendingCredentials = nil
            isCompleting = true
            Task {
                await auth.completeAuthorizingViaWeb(
                    stateId: pendingCredentials.stateId,
                    code: pendingCredentials.code
                )
                isCompleting = false
            }
        } else {
            auth.cancelAuthorizing()
        }
    }
}

#Preview {
    SignInView()
        .environment(AuthService())
}
