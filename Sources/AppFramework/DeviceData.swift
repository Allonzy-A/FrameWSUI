import Foundation
import AdServices
import UserNotifications

extension AppFramework {
    internal func collectDeviceData() async -> [String: String] {
        print("AppFramework: Starting device data collection")
        var deviceData: [String: String] = [:]
        deviceData["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        print("AppFramework: Bundle ID: \(deviceData["bundle_id"] ?? "unknown")")
        
        // Создаем таймаут таск
        let timeoutTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
        }
        
        // Собираем токены параллельно
        async let apnsTokenTask = getAPNSToken()
        async let attTokenTask = requestAttributionToken()
        
        // Ждем выполнения всех задач
        let (apnsToken, attToken) = await (apnsTokenTask, attTokenTask)
        
        deviceData["apns_token"] = apnsToken ?? "none"
        deviceData["att_token"] = attToken ?? "none"
        
        print("AppFramework: Collected data:")
        print("AppFramework: - APNS Token: \(deviceData["apns_token"] ?? "none")")
        print("AppFramework: - ATT Token: \(deviceData["att_token"] ?? "none")")
        
        return deviceData
    }
    
    private func getAPNSToken() async -> String? {
        print("AppFramework: Getting APNS token")
        // Здесь должна быть реальная логика получения токена
        // Временно возвращаем фиктивный токен
        return "test_apns_token_\(Int.random(in: 1000...9999))"
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