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
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.configuration.preferences.javaScriptEnabled = true
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webView.load(request)
        }
    }
}