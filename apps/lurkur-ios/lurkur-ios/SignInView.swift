import SwiftUI

struct SignInView: View {
    @Environment(AuthService.self) private var auth
    @State private var authURL: URL?
    @State private var isCompleting = false

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
        .sheet(isPresented: Binding(
            get: { authURL != nil },
            set: { if !$0 { dismissAuthSheet() } }
        )) {
            if let authURL {
                NavigationStack {
                    AuthWebView(url: authURL) { stateId, code in
                        self.authURL = nil
                        Task {
                            isCompleting = true
                            await auth.completeAuthorizingViaWeb(stateId: stateId, code: code)
                            isCompleting = false
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                dismissAuthSheet()
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

    private func dismissAuthSheet() {
        authURL = nil
        auth.cancelAuthorizing()
    }
}

#Preview {
    SignInView()
        .environment(AuthService())
}
