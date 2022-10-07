//
//  SDKResponse.swift
//  
//
//  Created by Zachary Shakked on 9/29/22.
//

import Foundation

struct SDKResponse: JSONObject {
    let libraries: [SDKLibrary]
    let configs: [SDKConfig]
    let error: SDKError?
    
    enum Key {
        static let libraries = "libraries"
        static let configs = "configs"
        static let error = "error"
    }
    
    init(json: JSON) {
        self.libraries = json["data"][Key.libraries].arrayValue.map(SDKLibrary.init)
        self.configs = json["data"][Key.configs].arrayValue.map(SDKConfig.init)

        if json[Key.error].exists() {
            self.error = SDKError(json: json["error"])
        } else {
            self.error = nil
        }
    }
}

