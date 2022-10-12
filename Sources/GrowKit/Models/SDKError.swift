//
//  SDKError.swift
//  
//
//  Created by Zachary Shakked on 9/29/22.
//

import Foundation

struct SDKError: JSONObject {
    let type: String
    let code: Int
    let message: [String]
    
    enum Key {
        static let type = "type"
        static let code = "code"
        static let message = "message"
    }
    
    init(json: JSON) {
        self.type = json[Key.type].stringValue
        self.code = json[Key.code].intValue
        self.message = json[Key.message].arrayValue.map({ $0.stringValue })
    }
    
    var jsonDictionary: [String : Any] {
        return [:]
    }
}
