//
//  GMLogger.swift
//  
//
//  Created by Zachary Shakked on 9/22/22.
//

import Foundation

public class GKLogger {
    public static let shared: GKLogger = GKLogger()
    
    public enum Category {
        case request
        case growthkit
        case module(GKLibrary.Type)
        
        var title: String {
            switch self {
            case .request:
                return "Request"
            case .growthkit:
                return "GrowthKit"
            case .module(let type):
                return type.name
            }
        }
    }
    
    public var enabledCategories: [Category] = [.growthkit]
    
    public func log(_ category: Category, _ log: String) {
        guard enabledCategories.contains(where: { $0.title == category.title }) else { return }
        print("<\(category.title)> \(log)")
    }
    
    func logRequest<T: JSONObject>(_ GKRequest: GKRequest<T>, headers: Bool, data: Data?, urlResponse: URLResponse?, error: Error?) {
        var logObject = GKRequest.logObject
        
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
