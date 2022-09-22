import UIKit

public class GitMart {
    
    public static let shared: GitMart = GitMart()
    
    private static let apiKeyStoreKey = "kApiKeyStoreKey"
    
    private let apiURL = "https://api.gitmart.co/v1"
    private let apiKeyInfoPlistkey = "GitMartAPIKey"
    private var apiKey: String {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GitMartAPIKey") as? String {
            return apiKey
        } else {
            fatalError("You must add to your Info.plist a key named \"GitMartAPIKey\" with a string value that is your GitMart API Key from your dashboard.")
        }
    }
    private static var librariesUsedKey: String {
        return "kLibrariesUsedKey-\(C.build())"
    }
    private var sdkResponse: SDKResponse?
    
    private init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: .main) { _ in
            print("application opened")
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            print("application became active")
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            print("application entered background")
        }
        start()
    }
    
    private func start() {
        makeRequest()
    }
    
    // MARK: - Library Storage
    
    private static func storeLibraryUsage(libraryID: String) {
        var current = librariesUsed()
        current.insert(libraryID)
        UserDefaults.standard.set(Array(current), forKey: GitMart.librariesUsedKey)
    }
    
    private static func librariesUsed() -> Set<String> {
        let libraryIDs: [String] = UserDefaults.standard.stringArray(forKey: GitMart.librariesUsedKey) ?? []
        return Set(libraryIDs)
    }
    
    // MARK: - Confirm Access
    
    @discardableResult
    public func confirmAccessToProject(libraryID: String, name: String, crashOnNo: Bool = false) -> Bool {
        // If the request didn't finish yet
        GitMart.storeLibraryUsage(libraryID: libraryID)
        
        if sdkResponse == nil {
            return true
        }
        
        guard let granted = sdkResponse?.data?.libraries?.granted, let billingError = sdkResponse?.data?.libraries?.billingErrors else {
            return true
        }
        
        if billingError.contains(where: { $0.id == libraryID }) {
            print("Warning - you are currently in billing error with the library \(name)<\(libraryID)>. Please visit your GitMart dashboard to resolve this error and ensure there is no interruption in service. We are still permitting access currently.")
            return true
        }
        
        guard granted.contains(where: { $0.id == libraryID }) else {
            if crashOnNo {
                fatalError("You are attempting to use a GitMart library that you haven't paid for: \(name)<\(libraryID)>. Please visit your GitMart account to update your billing information.")
            } else {
                print("You are attempting to use a GitMart library that you haven't paid for: \(name)<\(libraryID)>. Please visit your GitMart account to update your billing information. Eventually, we will start blocking your access but we are allowing you to continue using it now as a courtesy.")
                return false
            }
        }
        
        if let grantedLibrary = granted.filter({ $0.id == libraryID }).first {
            if grantedLibrary.isTrial {
                print("You are using \(name)<\(libraryID)> in trial mode right now. You can use it \(grantedLibrary.usageLeft) more times before your access will be expired. Please purchase this library on GitMart at https://gitmart.co/library/\(libraryID) to continue using it. Shipping a library in trial mode to production is against our Terms of Service and the license for an individual library and can result in legal action.")
            }
        }
        
                
        return true
    }
    
    public func crash(libraryID: String) {
        fatalError("You are attempting to use a GitMart library that you haven't paid for: \(libraryID). Please visit your GitMart account to update your billing information.")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func makeRequest() {
        let url = URL(string: "\(apiURL)/sdk/libraries")!
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "x-build-number": C.build(),
            "x-app-version": C.bundleVersion(),
            "x-country": C.currentLocale().countryCode ?? "",
            "x-bundle-id": Bundle.main.bundleIdentifier ?? "Unknown",
            "x-api-key": apiKey,
            "x-app-user-id": C.UserID(),
        ]
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.httpMethod = "POST"
            
            let body: [String: Any] = [
                "metadata": [
                    "ios_build_number": C.build(),
                    "ios_build_version": C.bundleVersion(),
                    "ios_app_country": C.currentLocale().countryCode ?? "",
                    "ios_app_timezone": C.Timezone_Name(),
                    "ios_bundle_id": Bundle.main.bundleIdentifier ?? "Unknown",
                    "ios_version": UIDevice.current.systemVersion,
                    "ios_app_user_id": C.UserID(),
                ],
                "library_ids": Array(GitMart.librariesUsed())
            ]
            
            let jsonBody = try JSONSerialization.data(withJSONObject: body)
            urlRequest.httpBody = jsonBody
            
            URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    print("no data")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    decoder.dateDecodingStrategy = .custom({ decoder in
                        let container = try decoder.singleValueContainer()
                        let dateStr = try container.decode(String.self)
                        return dateFormatter.date(from: dateStr)!
                    })
                    let res = try decoder.decode(SDKResponse.self, from: data)
                    
                    self.sdkResponse = res
                    
                    if let error = res.error {
                        print("GitMartError: \(error.type) (\(error.code)) - \(error.message)")
                    }
                } catch let err {
                    print(err)
                }
                
            }.resume()
        } catch let err {
            print(err)
        }
    }
}


struct SDKResponse: Codable {
    let data: SDKLibrariesResponse?
    let error: SDKError?
}

struct SDKLibrariesResponse: Codable {
    let libraries: SDKLibraryResponse?
    let error: SDKError?
}

struct SDKLibraryResponse: Codable {
    let granted: [SDKLibrary]
    let billingErrors: [SDKLibrary]
    
    private enum CodingKeys: String, CodingKey {
        case granted = "granted"
        case billingErrors = "billing_errors"
    }
}

struct SDKError: Codable {
    let type: String
    let code: Int
    let message: [String]
}

struct SDKLibrary: Codable {
    let id: String
    let name: String
    let isPurchased: Bool
    let isTrial: Bool
    let usageLeft: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case isPurchased = "is_purchased"
        case isTrial = "is_trial"
        case usageLeft = "usage_left"
    }
}
