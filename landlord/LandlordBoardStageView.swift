import SwiftUI
import Combine
import WebKit

struct LandlordBoardStageView: UIViewRepresentable {
    let startPath: URL
    let paths: RealmPaths
    let onReady: () -> Void

    func makeCoordinator() -> Keeper {
        Keeper(startPath: startPath, paths: paths, onReady: onReady)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)

        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator

        view.allowsBackForwardNavigationGestures = true
        view.scrollView.bounces = true
        view.scrollView.showsVerticalScrollIndicator = false
        view.scrollView.showsHorizontalScrollIndicator = false
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.backgroundColor = .black

        let refresh = UIRefreshControl()
        refresh.addTarget(
            context.coordinator,
            action: #selector(Keeper.handleRefresh(_:)),
            for: .valueChanged
        )
        view.scrollView.refreshControl = refresh

        context.coordinator.attach(view)
        context.coordinator.beginBoard()

        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }

    final class Keeper: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let startPath: URL
        private let paths: RealmPaths
        private let onReady: () -> Void

        weak var mainView: WKWebView?
        weak var popupView: WKWebView?

        private var baseHost: String?
        private var marksTimer: Timer?

        init(startPath: URL, paths: RealmPaths, onReady: @escaping () -> Void) {
            self.startPath = startPath
            self.paths = paths
            self.onReady = onReady
            self.baseHost = startPath.host?.lowercased()
        }

        func attach(_ view: WKWebView) {
            mainView = view
        }

        func beginBoard() {
            let request = URLRequest(url: startPath)
            mainView?.load(request)
        }

        // MARK: - Refresh

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            mainView?.reload()
        }

        // MARK: - WKNavigationDelegate

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            if webView === popupView {
                if let main = mainView,
                   let path = navigationAction.request.url {
                    main.load(URLRequest(url: path))
                }
                decisionHandler(.cancel)
                return
            }

            guard let path = navigationAction.request.url,
                  let schemeName = path.scheme?.lowercased()
            else {
                decisionHandler(.cancel)
                return
            }

            let allowed = schemeName == "http"
                || schemeName == "https"
                || schemeName == "about"

            guard allowed else {
                decisionHandler(.cancel)
                return
            }

            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView,
                     didStartProvisionalNavigation navigation: WKNavigation!) {
            stopMarksJob()
        }

        func webView(_ webView: WKWebView,
                     didFinish navigation: WKNavigation!) {
            handleFinish(in: webView)
        }

        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {
            handleFailure(in: webView)
        }

        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            handleFailure(in: webView)
        }

        private func handleFinish(in view: WKWebView) {
            onReady()
            view.scrollView.refreshControl?.endRefreshing()

            guard let current = view.url else {
                stopMarksJob()
                return
            }

            rememberTrailIfNeeded(current)

            let nowHost = current.host?.lowercased()
            let isBase: Bool
            if let base = baseHost, let now = nowHost, now == base {
                isBase = true
            } else {
                isBase = false
            }

            if isBase {
                stopMarksJob()
            } else {
                runMarksJob(for: current, in: view)
            }
        }

        private func handleFailure(in view: WKWebView) {
            onReady()
            view.scrollView.refreshControl?.endRefreshing()
            stopMarksJob()
        }

        // MARK: - WKUIDelegate

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {

            let popup = WKWebView(frame: .zero, configuration: configuration)
            popup.navigationDelegate = self
            popup.uiDelegate = self
            popupView = popup
            return popup
        }

        // MARK: - Trail memory

        private func rememberTrailIfNeeded(_ path: URL) {
            let startString = startPath.absoluteString
            let currentString = path.absoluteString
            guard currentString != startString else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                guard let self = self else { return }
                self.paths.storeTrailIfNeeded(path)
            }
        }

        // MARK: - Marks job

        private func runMarksJob(for path: URL, in board: WKWebView) {
            stopMarksJob()

            let mask = (path.host ?? "").lowercased()

            marksTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) {
                [weak board, weak paths] _ in
                guard let view = board, let store = paths else { return }

                view.configuration.websiteDataStore.httpCookieStore.getAllCookies { list in
                    let filtered = list.filter { cookie in
                        guard !mask.isEmpty else { return true }
                        return cookie.domain.lowercased().contains(mask)
                    }

                    let packed: [[String: Any]] = filtered.map { c in
                        var map: [String: Any] = [
                            "name": c.name,
                            "value": c.value,
                            "domain": c.domain,
                            "path": c.path,
                            "secure": c.isSecure,
                            "httpOnly": c.isHTTPOnly
                        ]
                        if let exp = c.expiresDate {
                            map["expires"] = exp.timeIntervalSince1970
                        }
                        if #available(iOS 13.0, *), let s = c.sameSitePolicy {
                            map["sameSite"] = s.rawValue
                        }
                        return map
                    }

                    store.saveMarks(packed)
                }
            }

            if let job = marksTimer {
                RunLoop.main.add(job, forMode: .common)
            }
        }

        private func stopMarksJob() {
            marksTimer?.invalidate()
            marksTimer = nil
        }
    }
}
