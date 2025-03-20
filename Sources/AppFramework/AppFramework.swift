import Foundation
import SwiftUI
import WebKit
import AdServices
import UserNotifications

public class AppFramework: ObservableObject {
    public static let shared = AppFramework()
    @Published public private(set) var webViewURL: String?
    internal let timeout: TimeInterval = 10
    
    internal var isFirstLaunch: Bool {
        get {
            !UserDefaults.standard.bool(forKey: "hasLaunched")
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: "hasLaunched")
        }
    }
    
    private init() {}
    
    public func initialize() async {
        if isFirstLaunch {
            await handleFirstLaunch()
        } else if let savedURL = UserDefaults.standard.string(forKey: "webViewURL") {
            self.webViewURL = savedURL
            NotificationCenter.default.post(name: .webViewShouldPresent, object: nil)
        }
    }
    
    internal func setWebViewURL(_ url: String) {
        self.webViewURL = url
    }
}

extension Notification.Name {
    public static let webViewShouldPresent = Notification.Name("webViewShouldPresent")
}