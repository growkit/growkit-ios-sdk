//
//  ChatRandomMessage.swift
//  
//
//  Created by Zachary Shakked on 9/20/22.
//

import Foundation

public struct ChatRandomMessage: Chat, JSONObject {
    public var message: String {
        return messages.randomElement() ?? ""
    }
    public let id: String
    public let messages: [String]
    public init(_ messages: [String]) {
        self.id = UUID().uuidString
        self.messages = messages
    }
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.messages = json["messages"].arrayValue.map({ $0.stringValue })
    }
    
    var jsonDictionary: [String : Any] {
        return [
            "type": "chatRandomMessage",
            "id": id,
            "messages": messages
        ]
    }
}
