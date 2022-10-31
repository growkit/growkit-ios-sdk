//
//  ChatUserMessage.swift
//  
//
//  Created by Zachary Shakked on 9/15/22.
//

import UIKit

public struct ChatUserMessage: Chat, JSONObject {
    public let id: String
    public let message: String
    public init(_ message: String) {
        self.id = UUID().uuidString
        self.message = message
    }
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.message = json["message"].stringValue
    }
    
    var jsonDictionary: [String : Any] {
        return [
            "type": "chatUserMessage",
            "id": id,
            "message": message,
        ]
    }
}
