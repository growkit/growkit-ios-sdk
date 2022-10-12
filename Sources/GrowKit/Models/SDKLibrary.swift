//
//  SDKLibrary.swift
//  
//
//  Created by Zachary Shakked on 9/29/22.
//

import Foundation

struct SDKLibrary: JSONObject {
    let id: String
    let name: String
    let isPurchased: Bool
    let isTrial: Bool
    let isBillingError: Bool
    let usageLeft: Int
    
    enum Key {
        static let id = "id"
        static let name = "name"
        static let isPurchased = "is_purchased"
        static let isTrial = "is_trial"
        static let isBillingError = "is_billing_error"
        static let usageLeft = "usage_left"
    }
    
    init(json: JSON) {
        self.id = json[Key.id].stringValue
        self.name = json[Key.name].stringValue
        self.isPurchased = json[Key.isPurchased].boolValue
        self.isTrial = json[Key.isTrial].boolValue
        self.isBillingError = json[Key.isBillingError].boolValue
        self.usageLeft = json[Key.usageLeft].intValue
    }
    
    var jsonDictionary: [String : Any] {
        return [:]
    }
}
