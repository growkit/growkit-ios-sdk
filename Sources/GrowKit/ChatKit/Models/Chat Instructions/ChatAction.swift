//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/16/22.
//

import UIKit



public enum ChatAction {
    case purchaseProduct(String)
    case restorePurchases
    case openURL(URL)
    case requestRating
    case requestWrittenReview
    case contactSupport
    case custom(String)
    case dismiss
    case showCancelButton
    case delay(TimeInterval)
    case rainingEmojis(String)
    case loopStart(String)
    case loopEnd(String)
    
    // case inputImage
    // case inputText
    // case uploadFile
    
    // webhook
    
    var loopID: String? {
        switch self {
        case .loopStart(let id):
            return id
        case .loopEnd(let id):
            return id
        default:
            return nil
        }
    }
    
    var name: String {
        switch self {
        case .purchaseProduct(let string):
            return "purchase product \(string)"
        case .restorePurchases:
            return "restore purchases"
        case .openURL(let url):
            return "open url \(url.absoluteURL)"
        case .requestRating:
            return "request rating"
        case .requestWrittenReview:
            return "request written review"
        case .contactSupport:
            return "contact support"
        case .custom(let string):
            return "other \(string)"
        case .dismiss:
            return "dismiss"
        case .showCancelButton:
            return "show cancel button"
        case .delay(let timeInterval):
            return "delay \(timeInterval)"
        case .rainingEmojis(let string):
            return "raining emojis \(string)"
        case .loopStart(let string):
            return "loop start \(string)"
        case .loopEnd(let string):
            return "loop end \(string)"
        }
    }
}
