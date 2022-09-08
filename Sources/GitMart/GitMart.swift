import UIKit

public class GitMart {
    
    public static let shared: GitMart = GitMart()
    
    private static let apiKeyStoreKey = "kApiKeyStoreKey"
    
    private let apiURL = "https://api.gitmart.co/v1"
    
    private var apiKey: String! {
        didSet {
            start()
        }
    }
    private var librariesResponse: SDKLibrariesResponse?
    
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
    }
    
    public func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func start() {
        makeRequest()
    }
    
    @discardableResult
    public func confirmAccessToProject(projectID: String, crashOnNo: Bool = true) -> Bool {
        guard apiKey != nil else {
            fatalError("You must call `GitMart.shared.configure(apiKey: \"YOUR KEY\")` first before doing anything.")
        }
        
        // If the request didn't finish yet
        if librariesResponse == nil {
            return true
        }
        
        guard let libraries = librariesResponse?.libraries else {
            return true
        }
        
        guard libraries.contains(where: { $0._id == projectID }) else {
            if crashOnNo {
                fatalError("You are attempting to use a GitMart library that you haven't paid for: \(projectID). Please visit your GitMart account to update your billing information.")
            } else {
                return false
            }
        }
        
        return true
    }
    
    public func crash(projectID: String) {
        fatalError("You are attempting to use a GitMart library that you haven't paid for: \(projectID). Please visit your GitMart account to update your billing information.")
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
            "x-api-key": apiKey
        ]
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.httpMethod = "GET"
            /*
             let jsonBody = try JSONSerialization.data(withJSONObject: body)
             urlRequest.httpBody = jsonBody
            */
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
                    let res = try decoder.decode(SDKLibrariesResponse.self, from: data)
                    self.librariesResponse = res
                    print(res)
                } catch let err {
                    print(err)
                }
                
            }.resume()
        } catch let err {
            print(err)
        }
    }
}

struct SDKLibrariesResponse: Codable {
    let libraries: [SDKLibrary]
    let user: SDKUser
    
    private enum CodingKeys: String, CodingKey {
        case libraries = "data"
        case user
    }
}

struct SDKLibrary: Codable {
    let _id: String
    let name: String
    let creator: String
    let description: String
    let gitURL: URL
    let price: Double
    let isReviewed: Bool
    let createdAt: Date
    let updatedAt: Date
    let __v: Int
}

struct SDKUser: Codable {
    let _id: String
    let name: String
    let profilePhotoURL: URL?
    let firebaseID: String
    let email: String
    let createdAt: Date
    let updatedAt: Date
    let __v: Int
}
