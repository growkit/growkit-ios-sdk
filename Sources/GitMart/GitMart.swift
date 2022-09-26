import UIKit

public class GitMart {
    
    public static var shared: GitMart {
        guard _shared.didCallConfigure else {
            fatalError("You must called `GitMart.shared.configure([])` before using any GitMart libraries. See our documentation for more instructions. You must provide all the GitMart libraries you are using in the function. For example, `GitMart.shared.configure([ChatKit.self, PowerButton.self])`.")
        }
        return _shared
    }
    private static let _shared: GitMart = GitMart()
    public static let triggerNotification: Notification.Name =  Notification.Name(rawValue: "kGitMartTriggerNotification")
    
    // Build added so that cached libraries are reset on every new build (if a user decided to remove libraries)
    private static var librariesUsedKey: String {
        return "kLibrariesUsedKey-\(C.build())"
    }
    private let jsonURLString = "https://gitmartco.nyc3.cdn.digitaloceanspaces.com/gitmart.json"
    private var sdkResponse: SDKResponse?
    private var sdkRequest: GMRequest<SDKResponse>?
    private var json: [String: Any]?
    private var didCallConfigure: Bool = false
    
    private init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: .main) { _ in
            // self?.makeEventRequest(eventName: "Application Opened", parameters: [:])
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            // self?.makeEventRequest(eventName: "Application Became Active", parameters: [:])
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            // self?.makeEventRequest(eventName: "Application Entered Background", parameters: [:])
        }
        GMLogger.shared.logLevel = .everything
    }
    
    public static func configure(_ libraries: [GitMartLibrary.Type]) {
        libraries.forEach({ library in
            GitMart.storeLibraryUsage(libraryID: library.id)
            library.start()
        })
        GMLogger.shared.log(.GitMart, "LIBRARIES: \(libraries.map({ $0.id }))", logLevel: .everything)
        GitMart._shared.didCallConfigure = true
        
        GitMart.shared.start()
    }
    
    public func start() {
        makeLibraryRequest()
        makeJSONRequest()
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
    public func confirmAccessToProject(library: GitMartLibrary.Type, crashOnNo: Bool = false) -> Bool {
        GitMart.storeLibraryUsage(libraryID: library.id)
        
        if sdkResponse == nil {
            return true
        }
        
        guard let granted = sdkResponse?.data?.libraries?.granted, let billingError = sdkResponse?.data?.libraries?.billingErrors else {
            return true
        }
        
        if billingError.contains(where: { $0.id == library.id }) {
            GMLogger.shared.log(.GitMart, "Warning - you are currently in billing error with the library \(library.name)<\(library.id)>. Please visit your GitMart dashboard to resolve this error and ensure there is no interruption in service. We are still permitting access currently.", logLevel: .minimal)
            return true
        }
        
        guard granted.contains(where: { $0.id == library.id }) else {
            if crashOnNo {
                fatalError("You are attempting to use a GitMart library that you haven't paid for: \(library.name)<\(library.id)>. Please visit your GitMart account to update your billing information.")
            } else {
                GMLogger.shared.log(.GitMart, "You are attempting to use a GitMart library that you haven't paid for: \(library.name)<\(library.id)>. Please visit your GitMart account to update your billing information. Eventually, we will start blocking your access but we are allowing you to continue using it now as a courtesy.", logLevel: .minimal)
                return false
            }
        }
        
        if let grantedLibrary = granted.filter({ $0.id == library.id }).first {
            if grantedLibrary.isTrial {
                GMLogger.shared.log(.GitMart, "You are using \(library.name)<\(library.id)> in trial mode right now. You can use it \(grantedLibrary.usageLeft) more times before your access will be expired. Please purchase this library on GitMart at https://gitmart.co/library/\(library.id) to continue using it. Shipping a library in trial mode to production is against our Terms of Service and the license for an individual library and can result in legal action.", logLevel: .minimal)
            }
        }
        
        
        return true
    }
    
    // MARK: - Library Crash
    
    public func crash(libraryID: String) {
        fatalError("You are attempting to use a GitMart library that you haven't paid for: \(libraryID). Please visit your GitMart account to update your billing information.")
    }
    
    // MARK: - Triggers
    
    public func trigger(name: String) {
        let notification = Notification(name: GitMart.triggerNotification, object: name)
        NotificationCenter.default.post(notification)
    }
    
    // MARK: - JSON
    
    public func json(for library: GitMartLibrary.Type) -> [String: Any]? {
        if let json = self.json?[library.id] as? [String: Any] {
            return json
        }
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func makeLibraryRequest() {
        let request: GMRequest<SDKResponse> = GMRequest(endpoint: "/sdk/libraries", httpMethod: "POST")
        request.body = [
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
        request.onResponse = { (res: SDKResponse) in
            self.sdkResponse = res
        }
        request.onError = { err in
            print(err)
        }
        request.start()
        self.sdkRequest = request
    }
    
    private func makeEventRequest(eventName: String, parameters: [String: Any]) {
        let request: GMRequest<SDKResponse> = GMRequest(endpoint: "/sdk/events", httpMethod: "POST")
        request.body = [
            "metadata": [
                "ios_build_number": C.build(),
                "ios_build_version": C.bundleVersion(),
                "ios_app_country": C.currentLocale().countryCode ?? "",
                "ios_app_timezone": C.Timezone_Name(),
                "ios_bundle_id": Bundle.main.bundleIdentifier ?? "Unknown",
                "ios_version": UIDevice.current.systemVersion,
                "ios_app_user_id": C.UserID(),
            ],
            "event": eventName,
            "parameters": parameters
        ]
        request.onResponse = { /*[weak self]*/ (res: SDKResponse) in
            
        }
        request.onError = { err in
            print(err)
        }
        request.start()
    }
    
    private func makeJSONRequest() {
        let url = URL(string: jsonURLString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                print(json)
                self.json = json
            } catch let err {
                print(err)
            }
        }
        task.resume()
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
