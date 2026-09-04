import OSLog
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
        webView.uiDelegate = context.coordinator
        context.coordinator.attach(to: webView)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        coordinator.detach()
    }
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
        webView.uiDelegate = context.coordinator
        context.coordinator.attach(to: webView)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}

    static func dismantleNSView(_ nsView: WKWebView, coordinator: Coordinator) {
        coordinator.detach()
    }
}
#endif

extension AuthWebView {
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let onComplete: (_ stateId: String, _ code: String) -> Void
        private var didComplete = false
        private var webView: WKWebView?
        private var urlObservation: NSKeyValueObservation?

        init(onComplete: @escaping (_ stateId: String, _ code: String) -> Void) {
            self.onComplete = onComplete
        }

        func attach(to webView: WKWebView) {
            self.webView = webView
            urlObservation = webView.observe(\.url, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.handlePossibleRedirect(webView.url)
                }
            }
        }

        func detach() {
            urlObservation?.invalidate()
            urlObservation = nil
            webView = nil
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if handlePossibleRedirect(navigationAction.request.url) {
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            _ = handlePossibleRedirect(webView.url)
        }

        func webView(
            _ webView: WKWebView,
            didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
        ) {
            _ = handlePossibleRedirect(webView.url)
        }

        /// Load `target=_blank` / window.open navigations in the same web view (common in OAuth UIs).
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                if handlePossibleRedirect(url) {
                    return nil
                }
                webView.load(navigationAction.request)
            }
            return nil
        }

        @discardableResult
        private func handlePossibleRedirect(_ url: URL?) -> Bool {
            guard let url,
                  let (stateId, code) = Self.authRedirectCredentials(from: url),
                  !didComplete
            else { return false }

            didComplete = true
            LurkurLog.auth.info("OAuth redirect intercepted")
            webView?.stopLoading()
            onComplete(stateId, code)
            return true
        }

        /// Parses `state` + `code` from a Reddit OAuth redirect to `https://www.reddit.com`.
        static func authRedirectCredentials(from url: URL) -> (stateId: String, code: String)? {
            guard isRedditOAuthRedirect(url),
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let stateId = components.queryItems?.first(where: { $0.name == "state" })?.value,
                  let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
                  !stateId.isEmpty,
                  !code.isEmpty
            else { return nil }
            return (stateId, code)
        }

        /// Reddit may bounce through `www.` or bare host; match either with the configured redirect prefix.
        private static func isRedditOAuthRedirect(_ url: URL) -> Bool {
            let absolute = url.absoluteString
            if absolute.hasPrefix(AuthService.redirectURI) {
                return true
            }
            // Bare-host variant of the registered redirect.
            if absolute.hasPrefix("https://reddit.com") {
                return true
            }
            return false
        }
    }
}
