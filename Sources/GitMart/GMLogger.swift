//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/22/22.
//

import Foundation

public class GMLogger {
    public static let shared: GMLogger = GMLogger()
    
    public enum Category {
        case request
        case gitMart
        case module(GitMartLibrary.Type)
        
        var title: String {
            switch self {
            case .request:
                return "Request"
            case .gitMart:
                return "GitMart"
            case .module(let type):
                return type.name
            }
        }
    }
    
    public var enabledCategories: [Category] = [.gitMart,]
    
    public func log(_ category: Category, _ log: String) {
        guard enabledCategories.contains(where: { $0.title == category.title }) else { return }
        print("<\(category.title)> \(log)")
    }
    
    func logRequest<T: Codable>(_ gmRequest: GMRequest<T>, headers: Bool, data: Data?, urlResponse: URLResponse?, error: Error?) {
        var logObject = gmRequest.logObject
        
        if let data = data, let data = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            logObject["response"] = data
        }
        
        if let urlResponse = urlResponse as? HTTPURLResponse {
            logObject["statusCode"] = urlResponse.statusCode
        }
        
        if let error = error {
            logObject["error"] = error.localizedDescription
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: logObject, options: .prettyPrinted) {
            if let prettyRequest = String(data: jsonData, encoding: .utf8) {
                log(.request, "\(prettyRequest)")
            }
        }
    }
}
