//
//  SDKResponse.swift
//  
//
//  Created by Zachary Shakked on 9/29/22.
//

import Foundation

struct SDKResponse: Codable {
    let data: SDKLibrariesResponse?
    let error: SDKError?
}
