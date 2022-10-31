import UIKit
import SafariServices
import StoreKit

public protocol GKDelegate: AnyObject {
    func logAnalyticEvent(library: GKLibrary.Type, event: String, parameters: [String: Any]?)
    func handleAction(library: GKLibrary.Type, action: GKAction, controller: UIViewController?)
}

public enum GKAction {
    case purchaseProduct(String)
    case restorePurchases
    case openURL(URL)
    case requestRating
    case requestWrittenReview
    case contactSupport
    case other(String)
}

public class GrowKit {
    
    public static let version: String = "0.1.0"
    public static var shared: GrowKit {
        guard _shared.didCallConfigure else {
            fatalError("You must called `GitMart.shared.configure([])` before using any GitMart libraries. See our documentation for more instructions. You must provide all the GitMart libraries you are using in the function. For example, `GitMart.shared.configure([ChatKit.self, PowerButton.self])`.")
        }
        return _shared
    }
    public weak var delegate: GKDelegate?
    
    private static let _shared: GrowKit = GrowKit()
    
    // Build added so that cached libraries are reset on every new build (if a user decided to remove libraries)
 
    private var sdkResponse: SDKResponse?
    private var sdkRequest: GKRequest<SDKResponse>?
    private var json: [String: Any]?
    private var didCallConfigure: Bool = false
    private var libraries: [GKLibrary.Type] = []
    public var appID: String?
    
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
    }
    
    public static func configure() {
        _shared.libraries = [ChatKit.self]
        _shared.didCallConfigure = true
        _shared.libraries.forEach({ $0.start() })
        GrowKit.shared.start()
        
        GKLogger.shared.log(.growthkit, "LIBRARIES: \(_shared.libraries.map({ $0.id }))")
    }
    
    public func start() {
        makeLibraryRequest()
    }
    
    public func refresh(completion: @escaping (() -> ())) {
        makeLibraryRequest(completion: completion)
    }
    
    // MARK: - Confirm Access
    
    @discardableResult
    public func confirmAccessToProject(library: GKLibrary.Type, crashOnNo: Bool = false) -> Bool {
        guard libraries.contains(where: { $0.id == library.id }) else {
            fatalError("You are using a library (\(library.name) - \(library.id))) that you did not configure on app open. Please update your configure to include `\(library.self).self` in your GitMart.configure() call like so: `GitMart.configure([ChatKit.self])`.")
        }
        
        if sdkResponse == nil {
            return true
        }
        
        guard let library = sdkResponse?.libraries.filter({ $0.id == library.id }).first else {
            return true
        }
        
        if library.isBillingError {
            GKLogger.shared.log(.growthkit, "Warning - you are currently in billing error with the library \(library.name)<\(library.id)>. Please visit your GitMart dashboard to resolve this error and ensure there is no interruption in service. We are still permitting access currently.")
            return true
        }
        
        
        if library.isTrial {
            GKLogger.shared.log(.growthkit, "You are using \(library.name)<\(library.id)> in trial mode right now. You can use it \(library.usageLeft) more times before your access will be expired. Please purchase this library on GitMart at https://gitmart.co/library/\(library.id) to continue using it. Shipping a library in trial mode to production is against our Terms of Service and the license for an individual library and can result in legal action.")
        }
        
        guard library.isPurchased else {
            if crashOnNo {
                fatalError("You are attempting to use a GitMart library that you haven't paid for: \(library.name)<\(library.id)>. Please visit your GitMart account to update your billing information.")
            } else {
                GKLogger.shared.log(.growthkit, "You are attempting to use a GitMart library that you haven't paid for: \(library.name)<\(library.id)>. Please visit your GitMart account to update your billing information. Eventually, we will start blocking your access but we are allowing you to continue using it now as a courtesy.")
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Triggers
    
    public func logEvent(eventName: String, properties: [String: Any]) {
        libraries.forEach({
            $0.handleEvent(eventName: eventName, properties: properties)
        })
        GKEvents.storeEvent(eventName: eventName)
    }
    
    // MARK: - JSON
    
    public func json(for library: GKLibrary.Type) -> [String: Any]? {
        if let json = self.json?[library.id] as? [String: Any] {
            return json
        }
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func makeLibraryRequest(completion: (() -> ())? = nil) {
        let request: GKRequest<SDKResponse> = GKRequest(endpoint: "/sdk/libraries", httpMethod: "POST")
        request.body = [
            "metadata": [
                "ios_build_number": C.build(),
                "ios_build_version": C.bundleVersion(),
                "ios_app_country": C.currentLocale().countryCode ?? "",
                "ios_app_timezone": C.Timezone_Name(),
                "ios_bundle_id": Bundle.main.bundleIdentifier ?? "Unknown",
                "ios_version": UIDevice.current.systemVersion,
                "ios_app_user_id": C.UserID(),
                "ios_sdk_version": GrowKit.version,
            ],
            "libraries": libraries.map({ ["id": $0.id, "version": $0.version, "bundle_id": $0.bundleID] }),
            "events": GKEvents.loggedEvents(),
        ]
        request.onResponse = { (res: SDKResponse) in
            self.sdkResponse = res
            self.libraries.forEach({ library in
                if let libraryJSON = res.configs.filter({ $0.libraryID == library.id }).first {
                    library.jsonLoaded(dictionary: libraryJSON.json)
                }
            })
            completion?()
        }
        request.onError = { err in
            GKLogger.shared.log(.request, "err: \(err.localizedDescription)")
            completion?()
        }
        request.start()
        self.sdkRequest = request
    }
    
    private func makeEventRequest(eventName: String, parameters: [String: Any]) {
        let request: GKRequest<SDKResponse> = GKRequest(endpoint: "/sdk/events", httpMethod: "POST")
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
            GKLogger.shared.log(.request, "err: \(err.localizedDescription)")
        }
        request.start()
    }
    
}





