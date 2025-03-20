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
        
        let apnsToken = await withTaskGroup(of: String?.self) { group in
            // Добавляем задачу получения токена
            group.addTask {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // Ждем 1 секунду для инициализации
                return await APNSManager.shared.requestToken()
            }
            
            // Добавляем задачу таймаута
            group.addTask {
                try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 секунд таймаут
                return nil
            }
            
            // Ждем первый результат
            let result = await group.next()
            group.cancelAll()
            return result ?? nil
        }
        
        // Сохраняем полученный токен
        if let token = apnsToken {
            deviceData["apns_token"] = token
            print("AppFramework: Successfully received APNS token: \(token)")
        } else {
            deviceData["apns_token"] = "none"
            print("AppFramework: APNS token timeout or not received")
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