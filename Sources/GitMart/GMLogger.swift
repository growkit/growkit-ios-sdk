//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/22/22.
//

import Foundation

public class GMLogger {
    static let shared: GMLogger = GMLogger()
    
    enum LogLevel {
        case minimal, everything
    }
    
    enum Category: String {
        case request
        case GitMart
    }
    
    var logLevel: LogLevel = .everything
    
    func log(_ category: Category, _ log: String, logLevel: LogLevel) {
        if logLevel == self.logLevel {
            print("<\(category.rawValue)> \(log)")
        }
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
                log(.request, "\(prettyRequest)", logLevel: .everything)
            }
        }
    }
}
