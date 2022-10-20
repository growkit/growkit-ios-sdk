//
//  ChatInstruction.swift
//  
//
//  Created by Zachary Shakked on 10/1/22.
//

import Foundation

public struct ChatInstruction: Chat, JSONObject {
    public let action: ChatAction
    public let id: String
    
    public init(_ action: ChatAction) {
        self.action = action
        self.id = UUID().uuidString
    }
    
    init(json: JSON) {
        let action = json["action"].stringValue
        switch action {
        case "Purchase Product":
            let productID = json["productID"].stringValue
            self = ChatInstruction(.purchaseProduct(productID))
        case "Restore Purchases":
            self = ChatInstruction(.restorePurchases)
        case "Open URL":
            let urlString = json["url"].stringValue
            let url = URL(string: urlString)!
            self = ChatInstruction(.openURL(url))
        case "Request Rating":
            self = ChatInstruction(.requestRating)
        case "Request Review":
            self = ChatInstruction(.requestWrittenReview)
        case "Contact Support":
            self = ChatInstruction(.contactSupport)
        case "Dismiss":
            self = ChatInstruction(.dismiss)
        case "Show Cancel Button":
            self = ChatInstruction(.showCancelButton)
        case "Delay":
            let seconds = json["seconds"].doubleValue
            self = ChatInstruction(.delay(seconds))
        case "Raining Emojis":
            let emoji = json["emoji"].stringValue
            self = ChatInstruction(.rainingEmojis(emoji))
        case "Loop Start":
            let loopID = json["loopID"].stringValue
            self = ChatInstruction(.loopStart(loopID))
        case "Loop End":
            let loopID = json["loopID"].stringValue
            self = ChatInstruction(.loopEnd(loopID))
        case "Custom":
            let customAction = json["custom"].stringValue
            self = ChatInstruction(.custom(customAction))
        default:
            let customAction = json["custom"].stringValue
            self = ChatInstruction(.custom(customAction))
        }
    }
    
    public var jsonDictionary: [String : Any] {
        switch action {
        case .purchaseProduct(let productID):
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Purchase Product",
                "productID": productID
            ]
        case .restorePurchases:
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Restore Purchases",
            ]
        case .openURL(let url):
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Open URL",
                "url": url.absoluteString,
            ]
        case .requestRating:
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Request Rating",
            ]
        case .requestWrittenReview:
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Request Review",
            ]
        case .contactSupport:
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Contact Support",
            ]
        case .custom(let other):
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Custom",
                "custom": other
            ]
        case .dismiss:
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Dismiss",
            ]
        case .showCancelButton:
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Show Cancel Button",
            ]
        case .delay(let timeInterval):
            return [
                "chat": "chatInstruction",
                "action": "Delay",
                "seconds": timeInterval,
            ]
        case .rainingEmojis(let emoji):
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Raining Emojis",
                "emoji": emoji,
            ]
        case .loopStart(let loopID):
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Loop Start",
                "loopID": loopID,
            ]
        case .loopEnd(let loopID):
            return [
                "id": id,
                "type": "chatInstruction",
                "action": "Loop End",
                "loopID": loopID,
            ]
        }
    }
}
