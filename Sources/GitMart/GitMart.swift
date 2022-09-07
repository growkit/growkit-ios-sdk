import UIKit

public class GitMart {
    
    public static let shared: GitMart = GitMart()
    
    private static let apiKeyStoreKey = "kApiKeyStoreKey"
    
    private let apiURL = "https://api.gitmart.io/v1"
    
    private var apiKey: String?
    
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
    
    public func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func start() {
        
    }
    
    @discardableResult
    public func confirmAccessToProject(projectID: String, crashOnNo: Bool = true) -> Bool {
        guard apiKey != nil else {
            fatalError("You must call `GitMart.shared.configure(apiKey: \"YOUR KEY\")` first before doing anything.")
        }
        
        if 0 == 0 {
            return true
        } else {
            if crashOnNo {
                fatalError("You are attempting to use a GitMart library that you haven't paid for: \(projectID). Please visit your GitMart account to update your billing information.")
            } else {
                return false
            }
        }
    }
    
    public func crash(projectID: String) {
        fatalError("You are attempting to use a GitMart library that you haven't paid for: \(projectID). Please visit your GitMart account to update your billing information.")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func makeRequest() {
        let url = URL(string: "\(apiURL)/v1/tokens/check")!
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "x-build-number": C.build(),
            "x-app-version": C.bundleVersion(),
            "x-country": C.currentLocale().countryCode ?? "",
        ]
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.httpMethod = "POST"
            let body: [String: String] = [
                "token": "token",
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
//                    let file = try JSONDecoder().decode(UKUploadResponse.self, from: data)
//                    print(file)
                } catch let err {
//                    print(err)
                }
                
            }.resume()
        } catch let err {
            print(err)
        }
    }
}


