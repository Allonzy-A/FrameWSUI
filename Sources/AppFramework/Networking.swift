import Foundation

extension AppFramework {
    private func formatDomain(from bundleId: String) -> String {
        let cleanBundleId = bundleId.replacingOccurrences(of: ".", with: "")
        print("AppFramework: Formatted domain: \(cleanBundleId).top")
        return "\(cleanBundleId).top"
    }
    
    internal func handleFirstLaunch() async {
        print("AppFramework: Handling first launch")
        let deviceData = await collectDeviceData()
        let encodedData = encodeDeviceData(deviceData)
        print("AppFramework: Encoded data: \(encodedData)")
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let domain = formatDomain(from: bundleId)
        
        guard let url = URL(string: "https://\(domain)/indexn.php?data=\(encodedData)") else {
            print("AppFramework: Failed to create URL")
            return
        }
        
        print("AppFramework: Sending request to: \(url)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            print("AppFramework: Server response status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            
            if let responseURL = String(data: data, encoding: .utf8), !responseURL.isEmpty {
                print("AppFramework: Received URL: \(responseURL)")
                DispatchQueue.main.async {
                    self.setWebViewURL(responseURL)
                    UserDefaults.standard.set(responseURL, forKey: "webViewURL")
                    NotificationCenter.default.post(name: .webViewShouldPresent, object: nil)
                }
            } else {
                print("AppFramework: Received empty response")
            }
            isFirstLaunch = false
        } catch {
            print("AppFramework: Network error: \(error)")
        }
    }
    
    private func encodeDeviceData(_ data: [String: String]) -> String {
        // Создаем JSON строку
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        let base64String = jsonData?.base64EncodedString() ?? ""
        print("AppFramework: Original data: \(data)")
        print("AppFramework: Base64 encoded data: \(base64String)")
        return base64String
    }
}