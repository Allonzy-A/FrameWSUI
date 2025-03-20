import Foundation
import AdServices
import UserNotifications

extension AppFramework {
    private func collectDeviceData() async -> [String: String] {
        var deviceData: [String: String] = [:]
        
        async let apnsToken = requestPushNotifications()
        async let attToken = requestAttributionToken()
        deviceData["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        
        // Ожидаем получение данных с таймаутом
        let timeoutTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
        }
        
        // Собираем все токены
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                deviceData["apns_token"] = await apnsToken ?? "none"
            }
            group.addTask {
                deviceData["att_token"] = await attToken ?? "none"
            }
            
            await group.waitForAll()
        }
        
        return deviceData
    }
    
    private func requestPushNotifications() async -> String? {
        let center = UNUserNotificationCenter.current()
        let result = await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard result.0 else { return nil }
        return "test_token" // Временная заглушка
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