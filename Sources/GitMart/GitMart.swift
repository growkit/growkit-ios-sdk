import UIKit

public class GitMart {
    
    static let shared: GitMart = GitMart()
    
    private static let apiKeyStoreKey = "kApiKeyStoreKey"
    
    private let apiURL = "https://api.gitmart.io/v1"
    
    private var apiKey: String {
        if let key = UserDefaults.standard.string(forKey: GitMart.apiKeyStoreKey) {
            return key
        } else {
            fatalError("GitMart must be configured with an API key. Please call `GitMart.configure(apiKey: 'YOUR_KEY')` before doing anything.")
        }
    }
    
    private init() {
        start()
        
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: .main) { _ in
            print("application opened")
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            print("applicationxx`x` became active")
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            print("application entered background")
        }
    }
    
    public static func configure(apiKey: String) {
        UserDefaults.standard.set(apiKey, forKey: GitMart.apiKeyStoreKey)
    }
    
    public func start() {
        // URL Request to get status of projectID
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}




