//
//  File.swift
//  
//
//  Created by Zachary Shakked on 8/30/22.
//

import Foundation

internal struct C {
    struct Setting {
        static let userID = "kGrowthKitUserID"
    }
    
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
    
    static let setUserID: (String) -> () = { newUserID in
        UserDefaults.standard.setValue(newUserID, forKey: Setting.userID)
    }
    
    static let clearUserID: () -> () = {
        UserDefaults.standard.removeObject(forKey: Setting.userID)
    }
    
    static let UserID: () -> (String) = {
        if let userID = UserDefaults.standard.string(forKey: Setting.userID) {
            return userID
        }
        
        let newUserID = UUID().uuidString
        setUserID(newUserID)
        return newUserID
    }
    
    static let APIKey: () -> (String) = {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GrowthKitAPIKey") as? String {
            return apiKey
        } else {
            fatalError("You must add to your Info.plist a key named \"GrowthKitAPIKey\" with a string value that is your GrowthKit API Key from your dashboard.")
        }
    }
}
