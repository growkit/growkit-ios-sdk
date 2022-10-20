//
//  ChatMessageConditional.swift
//  
//
//  Created by Zachary Shakked on 9/15/22.
//

import UIKit

public struct ChatQuestion: Chat, JSONObject {
    public let id: String
    public let message: String
    public let options: [ChatOption]
        
    public init(message: String, options: [ChatOption]) {
        self.id = UUID().uuidString
        self.message = message
        self.options = options
    }
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.message = json["message"].stringValue
        self.options = json["options"].arrayValue.map({ ChatOption(json: $0) })
    }
    
    public var jsonDictionary: [String : Any] {
        return [
            "type": "chatQuestion",
            "id": id,
            "message": message,
            "options": options.map({ $0.jsonDictionary })
        ]
    }
}
