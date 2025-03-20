import Foundation
import SwiftUI
import WebKit
import AdServices
import UserNotifications

// Модификатор для простой инициализации
public extension View {
    func initializeAppFramework() -> some View {
        self.onAppear {
            Task {
                await AppFramework.shared.initialize()
            }
        }
    }
}

public struct AppFrameworkView: View {
    @StateObject private var framework = AppFramework.shared
    
    public init() {}
    
    public var body: some View {
        Group {
            if let _ = framework.webViewURL {
                WebViewComponent()
            } else {
                // Можно добавить индикатор загрузки или оставить пустым
                Color.clear
            }
        }
        .onAppear {
            Task {
                await framework.initialize()
            }
        }
    }
}

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

extension AppFramework: UNUserNotificationCenterDelegate {
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("AppFramework: Received APNS token: \(token)")
        UserDefaults.standard.set(token, forKey: "APNSToken")
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("AppFramework: Failed to register for remote notifications: \(error)")
    }
}