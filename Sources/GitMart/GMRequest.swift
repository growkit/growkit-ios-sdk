//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/22/22.
//

import UIKit

class GMRequest<T: Codable> {
    private let apiURL = "https://api.gitmart.co/v1"
    
    let endpoint: String
    let httpMethod: String
    
    var url: String {
        return "\(apiURL)\(endpoint)"
    }
    var body: [String: Any] = [:]
    var onResponse: ((T) -> ())?
    var onError: ((Error) -> ())?
    var headers: [String: String] = {
        return [
            "Content-Type": "application/json",
            "x-build-number": C.build(),
            "x-app-version": C.bundleVersion(),
            "x-country": C.currentLocale().countryCode ?? "",
            "x-bundle-id": Bundle.main.bundleIdentifier ?? "Unknown",
            "x-api-key": C.APIKey(),
            "x-app-user-id": C.UserID(),
        ]
    }()
    
    init(endpoint: String, httpMethod: String) {
        self.endpoint = endpoint
        self.httpMethod = httpMethod
    }
    
    @discardableResult
    func start() -> URLSessionDataTask? {
        let url = URL(string: url)!
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.httpMethod = httpMethod
            
            let jsonBody = try JSONSerialization.data(withJSONObject: body)
            urlRequest.httpBody = jsonBody
            
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
                GMLogger.shared.logRequest(self, headers: true, data: data, urlResponse: urlResponse, error: error)
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    decoder.dateDecodingStrategy = .custom({ decoder in
                        let container = try decoder.singleValueContainer()
                        let dateStr = try container.decode(String.self)
                        return dateFormatter.date(from: dateStr) ?? Date()
                    })
                    let res = try decoder.decode(T.self, from: data)
                    self.onResponse?(res)
                } catch let err {
                    self.onError?(err)
                }
            }
            
            task.resume()
            return task
        } catch let err {
            self.onError?(err)
            return nil
        }
    }
    
    var logObject: [String: Any] {
        return [
            "url": "\(httpMethod) \(url)",
            "headers": headers,
            "body": body
        ]
    }
}
