import Foundation
import SwiftUI
import WebKit
import AdServices
import UserNotifications

public class AppFramework: ObservableObject {
    public static let shared = AppFramework()
    @Published private(set) var webViewURL: String?
    private let timeout: TimeInterval = 10
    private var isFirstLaunch: Bool {
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
}

extension Notification.Name {
    static let webViewShouldPresent = Notification.Name("webViewShouldPresent")
}