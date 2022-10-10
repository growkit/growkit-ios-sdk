//
//  GitMartEvents.swift
//  
//
//  Created by Zachary Shakked on 10/10/22.
//

import Foundation

enum GitMartEvents {
    
    static var key: String {
        return "kGitMartEvents-\(C.build())"
    }
    
    static func storeEvent(eventName: String) {
        var loggedEvents: Set<String> = Set(loggedEvents())
        loggedEvents.insert(eventName)
        UserDefaults.standard.set(Array(loggedEvents), forKey: key)
    }
    
    static func loggedEvents() -> [String] {
        let loggedEvents = UserDefaults.standard.array(forKey: key) as? [String] ?? []
        return loggedEvents
    }
    
}
