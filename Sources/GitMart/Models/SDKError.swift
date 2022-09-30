//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/29/22.
//

import Foundation

struct SDKError: Codable {
    let type: String
    let code: Int
    let message: [String]
}
