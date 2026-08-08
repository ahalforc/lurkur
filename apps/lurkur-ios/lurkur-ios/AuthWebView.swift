import SwiftUI
import WebKit

#if os(iOS)
struct AuthWebView: UIViewRepresentable {
    let url: URL
    let onComplete: (_ stateId: String, _ code: String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#elseif os(macOS)
struct AuthWebView: NSViewRepresentable {
    let url: URL
    let onComplete: (_ stateId: String, _ code: String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
#endif

extension AuthWebView {
    final class Coordinator: NSObject, WKNavigationDelegate {
        private let onComplete: (_ stateId: String, _ code: String) -> Void
        private var didComplete = false

        init(onComplete: @escaping (_ stateId: String, _ code: String) -> Void) {
            self.onComplete = onComplete
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if let url = navigationAction.request.url,
               let (stateId, code) = Self.authRedirectCredentials(from: url),
               !didComplete
            {
                didComplete = true
                onComplete(stateId, code)
            }
            decisionHandler(.allow)
        }

        static func authRedirectCredentials(from url: URL) -> (stateId: String, code: String)? {
            guard url.absoluteString.hasPrefix(AuthService.redirectURI) else { return nil }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let stateId = components.queryItems?.first(where: { $0.name == "state" })?.value,
                  let code = components.queryItems?.first(where: { $0.name == "code" })?.value
            else { return nil }
            return (stateId, code)
        }
    }
}
