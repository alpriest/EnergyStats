//
//  PreciseDateTimeFormatter.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/04/2023.
//

import Foundation

public enum PreciseDateTimeFormatter {
    public static func localizedString(from seconds: Int) -> String {
        localizedString(from: seconds, minutesLabel: "m", secondsLabel: "s")
    }

    public static func localizedAccessibilityString(from seconds: Int) -> String {
        localizedString(from: seconds, minutesLabel: " " + String(accessibilityKey: .minutes), secondsLabel: " " + String(accessibilityKey: .seconds))
    }

    private static func localizedString(from seconds: Int, minutesLabel: String, secondsLabel: String) -> String {
        switch seconds {
        case 0 ..< 60:
            return "\(seconds)\(secondsLabel)"
        default:
            let minutes = seconds / 60
            let remainder = seconds % 60
            return "\(minutes)\(minutesLabel) \(remainder)\(secondsLabel)"
        }
    }
}

public extension DateFormatter {
    static let fullTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
