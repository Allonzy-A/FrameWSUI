import Foundation
import AdServices
import UserNotifications

extension AppFramework {
    internal func collectDeviceData() async -> [String: String] {
        print("AppFramework: Starting device data collection")
        var deviceData: [String: String] = [:]
        deviceData["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        print("AppFramework: Bundle ID: \(deviceData["bundle_id"] ?? "unknown")")
        
        // Запрашиваем разрешения для push-уведомлений
        let notificationSettings = await requestPushNotificationPermission()
        
        if notificationSettings.authorizationStatus == .authorized {
            print("AppFramework: Push notifications authorized, requesting token")
            if let token = await APNSManager.shared.requestToken() {
                deviceData["apns_token"] = token
            } else {
                deviceData["apns_token"] = "none"
            }
        } else {
            print("AppFramework: Push notifications not authorized")
            deviceData["apns_token"] = "none"
        }
        
        // Получаем attribution token
        if let attToken = await requestAttributionToken() {
            deviceData["att_token"] = attToken
        } else {
            deviceData["att_token"] = "none"
        }
        
        print("AppFramework: Collected data:")
        print("AppFramework: - APNS Token: \(deviceData["apns_token"] ?? "none")")
        print("AppFramework: - ATT Token: \(deviceData["att_token"] ?? "none")")
        
        return deviceData
    }
    
    private func requestPushNotificationPermission() async -> UNNotificationSettings {
        print("AppFramework: Requesting push notification permission")
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print("AppFramework: Push notification permission granted: \(granted)")
        } catch {
            print("AppFramework: Push notification permission error: \(error)")
        }
        
        return await UNUserNotificationCenter.current().notificationSettings()
    }
    
    private func requestAttributionToken() async -> String? {
        print("AppFramework: Requesting attribution token")
        if #available(iOS 14.3, *) {
            do {
                let token = try await AAAttribution.attributionToken()
                print("AppFramework: Attribution token received")
                return token
            } catch {
                print("AppFramework: Failed to get attribution token: \(error)")
                return nil
            }
        }
        print("AppFramework: Device doesn't support attribution token")
        return nil
    }
}