//
//  Chat.swift
//  
//
//  Created by Zachary Shakked on 9/15/22.
//

import UIKit

public protocol Chat  {
    var type: ChatType { get }
    var id: String { get }
}

public extension Chat {
    var type: ChatType {
        let typeString = String(describing: Self.self)
        return ChatType(chatType: typeString)!
    }
}

public enum ChatType {
    case chatMessage
    case chatUserMessage
    case chatRandomMessage
    case chatQuestion
    case chatInstruction
    case chatTextInput
    
    init?(chatType: String) {
        switch chatType.lowercased() {
        case "chatMessage".lowercased():
            self = .chatMessage
        case "chatUserMessage".lowercased():
            self = .chatUserMessage
        case "chatRandomMessage".lowercased():
            self = .chatRandomMessage
        case "chatQuestion".lowercased():
            self = .chatQuestion
        case "chatInstruction".lowercased():
            self = .chatInstruction
        case "chatTextInput".lowercased():
            self = .chatTextInput
        case "chatInstruction".lowercased():
            self = .chatInstruction
        default:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .chatMessage:
            return "chatMessage"
        case .chatUserMessage:
            return "chatUserMessage"
        case .chatRandomMessage:
            return "chatRandomMessage"
        case .chatQuestion:
            return "chatQuestion"
        case .chatInstruction:
            return "chatInstruction"
        case .chatTextInput:
            return "chatTextInput"
        }
    }
}
