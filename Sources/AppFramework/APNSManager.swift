import Foundation
import UIKit

class APNSManager: NSObject {
    static let shared = APNSManager()
    private var tokenCompletion: ((String?) -> Void)?
    private let tokenTimeout: TimeInterval = 5 // 5 секунд на получение токена
    
    override private init() {
        super.init()
    }
    
    func requestToken() async -> String? {
        return await withCheckedContinuation { continuation in
            self.tokenCompletion = { token in
                continuation.resume(returning: token)
            }
            
            // Запускаем таймер для таймаута
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                
                // Таймаут для получения токена
                DispatchQueue.main.asyncAfter(deadline: .now() + self.tokenTimeout) {
                    if self.tokenCompletion != nil {
                        print("AppFramework: APNS token request timed out after \(self.tokenTimeout) seconds")
                        self.tokenCompletion?(nil)
                        self.tokenCompletion = nil
                    }
                }
            }
        }
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("AppFramework: Successfully received APNS token: \(token)")
        tokenCompletion?(token)
        tokenCompletion = nil
    }
    
    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        print("AppFramework: Failed to register for remote notifications: \(error)")
        tokenCompletion?(nil)
        tokenCompletion = nil
    }
} 