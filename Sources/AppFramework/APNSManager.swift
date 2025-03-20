import Foundation
import UIKit

class APNSManager: NSObject {
    static let shared = APNSManager()
    private var tokenCompletion: ((String?) -> Void)?
    
    override private init() {
        super.init()
    }
    
    func requestToken() async -> String? {
        return await withCheckedContinuation { continuation in
            self.tokenCompletion = { token in
                continuation.resume(returning: token)
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
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