//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/15/22.
//

import UIKit

let libraryID = "632b6c551015bcf8ac4843d9"

public class ChatSequence {
    
    public let id: String
    public let name: String
    public var readingSpeed: Double = 1.0
    public var analyticEventBlock: ((ChatAnalyticEvent) -> ())? = nil
    
    let allChats: [Chat]
    public private(set) var chats: [Chat]
    
    var levels: [[Chat]] = []
    weak var controller: UIViewController?
    
    var addMessage: ((String) -> ())? = nil
    var addUserMessage: ((String) -> ())? = nil
    var showButtons: ((ChatQuestion) -> ())? = nil
    var showTextInput: ((ChatTextInput) -> ())? = nil
    var hideButtons: (() -> ())? = nil
    var showCancelButton: (() -> ())? = nil
    var dismiss: (() -> ())? = nil
    var startTyping: (() -> ())? = nil
    var stopTyping: (() -> ())? = nil
    
    var isWaitingForButtonPressed: Bool = false
    var previousAnswer: String?
    var startTime: Date = Date()
    
    var isStopped: Bool = false
        
    public init(id: String, chats: [Chat]) {
        self.id = id
        self.chats = chats
        self.allChats = chats
        self.name = id
        
        ChatKit.shared.registerChatSequence(sequence: self)
    }
    
    init(json: JSON) {
        self.name = json["name"].stringValue
        self.id = json["id"].stringValue
        self.chats = json["chats"].arrayValue.map({ AnyChat.chat(for: $0) }).compactMap({ $0 })
        self.allChats = self.chats
        
        if let readingSpeed = json["readingSpeed"].double {
            self.readingSpeed = readingSpeed
        }
    }
    
    public var json: String {
        let sequenceObject: [String: Any] = [
            "id": id,
            "readingSpeed": readingSpeed,
            "chats": chats.map({ ($0 as? JSONObject)?.jsonDictionary }).compactMap({ $0 })
        ]
        
        let data = try! JSONSerialization.data(withJSONObject: sequenceObject, options: .prettyPrinted)
        let string = String(data: data, encoding: .utf8)!
        return string
    }
    
    public func copy() -> ChatSequence {
        let sequence = ChatSequence(id: id, chats: chats)
        sequence.readingSpeed = readingSpeed
        sequence.analyticEventBlock = analyticEventBlock
        return sequence
    }
    
    func start() {
        GKLogger.shared.log(.module(ChatKit.self), "Starting chat sequence: \(id)")
        let event = ChatAnalyticEvent.started(self)
        GrowKit.shared.delegate?.logAnalyticEvent(library: ChatKit.self, event: event.eventName, parameters: event.parameters)
        
        continueChat()
        startTime = Date()
    }
    
    func stop() {
        isStopped = true
    }
    
    private func next() -> Chat? {
        if chats.count > 0 {
            let first = chats.removeFirst()
            return first
        }
        return nil
    }
    
    func nextChat() -> Chat? {
        return chats.first
    }
    
    func continueChat() {
        guard !isStopped else {
            self.chats = []
            return
        }
        
        GKLogger.shared.log(.module(ChatKit.self), "Next Chat: \(nextChat()?.type.description ?? "")")
        guard let next = self.next() else {
            if self.levels.count > 0 {
                self.chats = self.levels.removeLast()
                self.continueChat()
            } else {
                self.dismissed()
            }
            return
        }
        
        switch next.type {
        case .chatMessage:
            if let chatMessage = next as? ChatMessage {
                var nextMessage = chatMessage.message
                if let previousAnswer = previousAnswer {
                    nextMessage = nextMessage.replacingOccurrences(of: "%@", with: previousAnswer)
                }
                let estimatedReadingTime = readingTime(nextMessage)
                
                self.addMessage?(nextMessage)
                self.startTyping?()
                DispatchQueue.main.asyncAfter(deadline: .now() + estimatedReadingTime) {
                    self.stopTyping?()
                    self.continueChat()
                }
            }
        case .chatUserMessage:
            if let chatUserMessage = next as? ChatUserMessage {
                var nextMessage = chatUserMessage.message
                if let previousAnswer = previousAnswer {
                    nextMessage = nextMessage.replacingOccurrences(of: "%@", with: previousAnswer)
                }
                let estimatedReadingTime = readingTime(nextMessage)
                self.addUserMessage?(nextMessage)
                DispatchQueue.main.asyncAfter(deadline: .now() + estimatedReadingTime) {
                    self.continueChat()
                }
            }
        case .chatQuestion:
            
            if let chatMessageConditional = next as? ChatQuestion {
                var nextMessage = chatMessageConditional.message
                if let previousAnswer = previousAnswer {
                    nextMessage = nextMessage.replacingOccurrences(of: "%@", with: previousAnswer)
                }
                if nextMessage != "" {
                    self.addMessage?(nextMessage)
                }
                let estimatedReadingTime = readingTime(nextMessage)

                DispatchQueue.main.asyncAfter(deadline: .now() + estimatedReadingTime) {
                    self.stopTyping?()
                    self.showButtons?(chatMessageConditional)
                }
            }
        case .chatRandomMessage:
            if let chatRandomMessage = next as? ChatRandomMessage {
                let nextMessage = chatRandomMessage.message
                let estimatedReadingTime = readingTime(nextMessage)
                self.addMessage?(nextMessage)
                self.startTyping?()
                DispatchQueue.main.asyncAfter(deadline: .now() + estimatedReadingTime) {
                    self.stopTyping?()
                    self.continueChat()
                }
            }
        case .chatTextInput:
            if let chatTextInput = next as? ChatTextInput {
                var nextMessage = chatTextInput.message
                if let previousAnswer = previousAnswer {
                    nextMessage = nextMessage.replacingOccurrences(of: "%@", with: previousAnswer)
                }
                self.addMessage?(nextMessage)
                let estimatedReadingTime = readingTime(nextMessage)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + estimatedReadingTime) {
                    self.stopTyping?()
                    self.showTextInput?(chatTextInput)
                }
            }
            
        case .chatInstruction:
            if let chatInstruction = next as? ChatInstruction {
                let event = ChatAnalyticEvent.instruction(self, chatInstruction.action)
                GrowKit.shared.delegate?.logAnalyticEvent(library: ChatKit.self, event: event.eventName, parameters: event.parameters)
                
                switch chatInstruction.action {
                case .openURL(let url):
                    GrowKit.shared.delegate?.handleAction(library: ChatKit.self, action: .openURL(url), controller: controller)
                    self.continueChat()
                    
                case .showCancelButton:
                    self.showCancelButton?()
                    self.continueChat()
                    
                case .rainingEmojis(let emoji):
                    FallingEmojiView.shared.show(emoji: emoji)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
                        self.continueChat()
                    }
                    
                case .custom(let action):
                    GrowKit.shared.delegate?.handleAction(library: ChatKit.self, action: .other(action), controller: controller)
                    self.continueChat()
                    
                case .contactSupport:
                    GrowKit.shared.delegate?.handleAction(library: ChatKit.self, action: .contactSupport, controller: controller)
                    self.continueChat()

                case .delay(let delay):
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
                        self.continueChat()
                    }
                    
                case .dismiss:
                    self.dismiss?()
                    
                case .loopStart(_):
                    self.continueChat()
                    
                case .loopEnd(let id):
                    if let indexOfStart = self.allChats.firstIndex(where: { ($0 as? ChatInstruction)?.action.loopID == id }) {
                        self.chats = Array(self.allChats[indexOfStart..<self.allChats.count])
                        self.continueChat()
                    }
                case .requestRating:
                    GrowKit.shared.delegate?.handleAction(library: ChatKit.self, action: .requestRating, controller: controller)
                    self.continueChat()
                    
                case .requestWrittenReview:
                    GrowKit.shared.delegate?.handleAction(library: ChatKit.self, action: .requestWrittenReview, controller: controller)
                    self.continueChat()
                    
                case .purchaseProduct(let product):
                    GrowKit.shared.delegate?.handleAction(library: ChatKit.self, action: .purchaseProduct(product), controller: controller)
                    self.continueChat()

                case .restorePurchases:
                    GrowKit.shared.delegate?.handleAction(library: ChatKit.self, action: .restorePurchases, controller: controller)
                    self.continueChat()
                }
            }
            break
        }
    }

    func userTappedButton(index: Int, buttonText: String, chat: ChatQuestion, controller: ChatViewController) {
        self.hideButtons?()
        self.previousAnswer = buttonText
        
        let userMessage = chat.options[index].option
        self.addUserMessage?(userMessage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + readingTime(userMessage)) {
            if chat.options.count > 0 {
                self.levels.append(self.chats)
                let selectedOption = chat.options[index]
                self.chats = selectedOption.chats
                self.continueChat()
            } else {
                self.continueChat()
            }
        }
        
        let analytic = ChatButtonAnalytic(chat: chat, selectedOption: buttonText)
        let event = ChatAnalyticEvent.buttonPressed(self, analytic)
        GrowKit.shared.delegate?.logAnalyticEvent(library: ChatKit.self, event: event.eventName, parameters: event.parameters)
    }
    
    func userEnteredText(text: String, chat: ChatTextInput, controller: ChatViewController) {
        self.previousAnswer = text
        self.addUserMessage?(text)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + readingTime(text) + 1.0) {
            self.continueChat()
        }
        
        let analytic = ChatTextInputAnalytic(chat: chat, enteredText: text)
        let event = ChatAnalyticEvent.textEntered(self, analytic)
        GrowKit.shared.delegate?.logAnalyticEvent(library: ChatKit.self, event: event.eventName, parameters: event.parameters)
    }
    
    func dismissed() {
        let elapsedTime = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
        self.analyticEventBlock?(ChatAnalyticEvent.dimissed(self, elapsedTime))
        let event = ChatAnalyticEvent.dimissed(self, elapsedTime)
        GrowKit.shared.delegate?.logAnalyticEvent(library: ChatKit.self, event: event.eventName, parameters: event.parameters)
    }
    
    internal func readingTime(_ string: String) -> Double {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = string.components(separatedBy: chararacterSet)
        let words = components.filter { !$0.isEmpty }
        
        return (1 + Double(words.count) * 0.2) / readingSpeed
    }
}
