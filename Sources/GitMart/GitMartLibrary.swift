//
//  File.swift
//  
//
//  Created by Zachary Shakked on 9/26/22.
//

import Foundation

public protocol GitMartLibrary {
    static var id: String { get }
    static var name: String { get }
    static func start()
}
