import Foundation
import AdServices
import UserNotifications

extension AppFramework {
    internal func collectDeviceData() async -> [String: String] {
        var deviceData: [String: String] = [:]
        deviceData["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        
        // Создаем таймаут таск
        let timeoutTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
        }
        
        // Собираем токены параллельно
        async let apnsTokenTask = requestPushNotifications()
        async let attTokenTask = requestAttributionToken()
        
        // Ждем выполнения всех задач
        let (apnsToken, attToken) = await (apnsTokenTask, attTokenTask)
        
        deviceData["apns_token"] = apnsToken ?? "none"
        deviceData["att_token"] = attToken ?? "none"
        
        return deviceData
    }
    
    private func requestPushNotifications() async -> String? {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted ? "test_token" : nil
        } catch {
            print("Push notification authorization failed: \(error)")
            return nil
        }
    }
    
    private func requestAttributionToken() async -> String? {
        if #available(iOS 14.3, *) {
            do {
                let token = try await AAAttribution.attributionToken()
                return token
            } catch {
                print("Failed to get attribution token: \(error)")
                return nil
            }
        }
        return nil
    }
}