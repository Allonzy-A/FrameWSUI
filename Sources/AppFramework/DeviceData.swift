import Foundation
import AdServices
import UserNotifications
import UIKit

extension AppFramework {
    internal func collectDeviceData() async -> [String: String] {
        print("AppFramework: Starting device data collection")
        var deviceData: [String: String] = [:]
        deviceData["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        print("AppFramework: Bundle ID: \(deviceData["bundle_id"] ?? "unknown")")
        
        // Ждем получения APNS токена
        print("AppFramework: Waiting for APNS token (10 seconds max)...")
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // Ждем 1 секунду для инициализации
            if let token = await withTimeout(seconds: 10) {
                await APNSManager.shared.requestToken()
            } {
                deviceData["apns_token"] = token
                print("AppFramework: Successfully received APNS token: \(token)")
            } else {
                deviceData["apns_token"] = "none"
                print("AppFramework: APNS token timeout or not received")
            }
        } catch {
            deviceData["apns_token"] = "none"
            print("AppFramework: Error getting APNS token: \(error)")
        }
        
        // Получаем attribution token
        if let attToken = await requestAttributionToken() {
            deviceData["att_token"] = attToken
        } else {
            deviceData["att_token"] = "none"
        }
        
        print("AppFramework: Final collected data:")
        print("AppFramework: - APNS Token: \(deviceData["apns_token"] ?? "none")")
        print("AppFramework: - ATT Token: \(deviceData["att_token"] ?? "none")")
        
        return deviceData
    }
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async -> T?) async -> T? {
        return await withTaskGroup(of: Optional<T>.self) { group in
            // Добавляем основную операцию
            group.addTask {
                return await operation()
            }
            
            // Добавляем таймаут
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                return nil
            }
            
            // Ждем первый результат
            let result = await group.next()
            group.cancelAll()
            return result ?? nil
        }
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