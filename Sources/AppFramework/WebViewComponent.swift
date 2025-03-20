import SwiftUI
import WebKit
import UIKit

public struct WebViewComponent: View {
    @StateObject private var webViewModel = WebViewModel()
    
    public init() {}
    
    public var body: some View {
        WebView(url: webViewModel.url)
            .edgesIgnoringSafeArea(.all)
            .statusBar(hidden: true)
            .background(Color.black)
    }
}

class WebViewModel: ObservableObject {
    @Published var url: URL?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleWebViewPresentation), name: .webViewShouldPresent, object: nil)
    }
    
    @objc private func handleWebViewPresentation() {
        if let urlString = UserDefaults.standard.string(forKey: "webViewURL"),
           let url = URL(string: urlString) {
            DispatchQueue.main.async {
                self.url = url
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        
        // Добавляем наблюдателя за загрузкой
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            print("AppFramework: Loading URL in WebView: \(url)")
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // Наблюдение за состоянием загрузки
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "loading" {
                if let webView = object as? WKWebView {
                    print("AppFramework: WebView loading state changed: \(webView.isLoading)")
                }
            }
        }
        
        // Обработка ошибок загрузки
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("AppFramework: WebView failed to load: \(error)")
        }
        
        // Успешная загрузка
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("AppFramework: WebView successfully loaded")
        }
        
        // Начало загрузки
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("AppFramework: WebView started loading")
        }
    }
}