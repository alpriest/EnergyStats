//
//  UserAgent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import Foundation

public enum UserAgent {
    public static func description() -> String {
        "Energy-Stats/\(platform)/\(UserAgent.appVersion)"
    }

    private static var platform: String {
#if targetEnvironment(macCatalyst)
        "macOS"
#else
        "iOS"
#endif
    }

    private static var appVersion: String {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleShortVersionString"] as! String
    }
}
