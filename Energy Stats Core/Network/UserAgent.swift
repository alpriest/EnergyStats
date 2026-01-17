//
//  UserAgent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import Foundation

public enum UserAgent {
    public static func description() -> String {
        "Energy-Stats/\(platform)/\(AppVersion.description)"
    }

    private static var platform: String {
#if targetEnvironment(macCatalyst)
        "macOS"
#else
        "iOS"
#endif
    }
}

public enum AppVersion {
    public static var description: String {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleShortVersionString"] as! String
    }
}
