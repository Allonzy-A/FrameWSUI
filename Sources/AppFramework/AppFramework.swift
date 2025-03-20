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
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onAppear {
            Task {
                await framework.initialize()
            }
        }
    }
}

public class AppFramework: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    public static let shared = AppFramework()
    @Published public private(set) var webViewURL: String?
    internal let timeout: TimeInterval = 10
    private let apnsManager = APNSManager.shared
    
    internal var isFirstLaunch: Bool {
        get {
            !UserDefaults.standard.bool(forKey: "hasLaunched")
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: "hasLaunched")
        }
    }
    
    private override init() {
        super.init()
        print("AppFramework: Initialized")
        // Устанавливаем делегат для уведомлений
        UNUserNotificationCenter.current().delegate = self
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
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } catch {
            print("AppFramework: Push authorization failed: \(error)")
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // MARK: - Remote Notifications
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        apnsManager.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        apnsManager.didFailToRegisterForRemoteNotifications(withError: error)
    }
}

extension Notification.Name {
    public static let webViewShouldPresent = Notification.Name("webViewShouldPresent")
}