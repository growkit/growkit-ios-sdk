//
//  File.swift
//  
//
//  Created by Zachary Shakked on 8/30/22.
//

import Foundation

internal struct C {
    static let bundleVersion: () -> String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        return version
    }

    static let build: () -> String = {
        let appBundle = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        return appBundle
    }

    static let Timezone_Name: () -> (String) = {
        return TimeZone.autoupdatingCurrent.identifier
    }

    static let Timezone_GMT: () -> (String) = {
        return "\(NSTimeZone.local.secondsFromGMT() / 3600)"
    }

    static let currentLocale: () -> (NSLocale) = {
        return (Locale.current as NSLocale)
    }

    static let defaultLocale: () -> (NSLocale) = {
        return NSLocale(localeIdentifier: "en_US")
    }
}
