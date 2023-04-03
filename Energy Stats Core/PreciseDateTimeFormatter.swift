//
//  PreciseDateTimeFormatter.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/04/2023.
//

import Foundation

public class PreciseDateTimeFormatter {
    public static func localizedString(from seconds: Int) -> String {
        switch seconds {
        case 0 ..< 60:
            return "\(seconds)s"
        default:
            let minutes = seconds / 60
            let remainder = seconds % 60
            return "\(minutes)m \(remainder)s"
        }
    }
}
