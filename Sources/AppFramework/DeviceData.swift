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
        async let apnsTokenTask = requestAPNSToken()
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
    
    private func requestAPNSToken() async -> String? {
        print("AppFramework: Requesting APNS token")
        
        // Создаем семафор для синхронного получения токена
        let semaphore = DispatchSemaphore(value: 0)
        var token: String?
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        // Ждем получения токена максимум 5 секунд
        _ = semaphore.wait(timeout: .now() + 5)
        
        if let deviceToken = UserDefaults.standard.string(forKey: "APNSToken") {
            print("AppFramework: Retrieved APNS token: \(deviceToken)")
            return deviceToken
        } else {
            print("AppFramework: Failed to get APNS token")
            return nil
        }
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