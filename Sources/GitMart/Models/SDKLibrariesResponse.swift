//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/29/22.
//

import Foundation

struct SDKLibraryResponse: Codable {
    let granted: [SDKLibrary]
    let billingErrors: [SDKLibrary]
    
    private enum CodingKeys: String, CodingKey {
        case granted = "granted"
        case billingErrors = "billing_errors"
    }
}
