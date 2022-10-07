//
//  SDKConfig.swift
//  
//
//  Created by Zachary Shakked on 10/4/22.
//

import UIKit

struct SDKConfig: JSONObject {
    
    let libraryID: String
    let libraryBundleID: String
    let schemaVersion: String
    let libraryVersion: String
    let lastUpdated: Date
    let json: [String: Any]
    
    enum Key {
        static let libraryID = "library_id"
        static let libraryBundleID = "library_bundle_id"
        static let schemaVersion = "schema_version"
        static let libraryVersion = "library_version"
        static let lastUpdated = "last_updated"
        static let json = "json"
    }
    
    init(json: JSON) {
        self.libraryID = json[Key.libraryID].stringValue
        self.libraryBundleID = json[Key.libraryBundleID].stringValue
        self.schemaVersion = json[Key.schemaVersion].stringValue
        self.libraryVersion = json[Key.libraryVersion].stringValue
        self.lastUpdated = json[Key.lastUpdated].dateValue
        self.json = json[Key.json].value as? [String: Any] ?? [:]
    }
}
