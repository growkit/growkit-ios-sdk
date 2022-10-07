//
//  GitMartLibrary.swift
//  
//
//  Created by Zachary Shakked on 9/26/22.
//

import Foundation

public protocol GitMartLibrary {
    static var id: String { get }
    static var name: String { get }
    static var version: String { get }
    static var bundleID: String { get }
    
    static func start()
    
    static func jsonLoaded(dictionary: [String: Any])
    static func handleEvent(eventName: String, properties: [String: Any])
}
