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
    
    private init() {
        print("AppFramework: Initialized")
        // Запрашиваем разрешение на пуш сразу при инициализации
        Task {
            await requestPushAuthorization()
        }
    }
    
    public func initialize() async {
        print("AppFramework: Starting initialization")
        if isFirstLaunch {
            print("AppFramework: First launch detected")
            await handleFirstLaunch()
        } else if let savedURL = UserDefaults.standard.string(forKey: "webViewURL") {
            print("AppFramework: Using saved URL: \(savedURL)")
            self.webViewURL = savedURL
            NotificationCenter.default.post(name: .webViewShouldPresent, object: nil)
        }
    }
    
    internal func setWebViewURL(_ url: String) {
        print("AppFramework: Setting WebView URL: \(url)")
        self.webViewURL = url
    }
    
    private func requestPushAuthorization() async {
        print("AppFramework: Requesting push notifications authorization")
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            print("AppFramework: Push authorization result: \(granted)")
        } catch {
            print("AppFramework: Push authorization failed: \(error)")
        }
    }
}

extension Notification.Name {
    public static let webViewShouldPresent = Notification.Name("webViewShouldPresent")
}