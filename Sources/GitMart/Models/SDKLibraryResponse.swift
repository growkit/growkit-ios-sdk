//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/29/22.
//

import Foundation

struct SDKLibrariesResponse: Codable {
    let libraries: SDKLibraryResponse?
    let error: SDKError?
}
