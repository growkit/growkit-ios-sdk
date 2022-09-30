//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/29/22.
//

import Foundation

struct SDKLibrary: Codable {
    let id: String
    let name: String
    let isPurchased: Bool
    let isTrial: Bool
    let usageLeft: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case isPurchased = "is_purchased"
        case isTrial = "is_trial"
        case usageLeft = "usage_left"
    }
}
