//
//  FoxEssCloudParseStrategy.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/09/2022.
//

import Foundation

struct FoxEssCloudParseStrategy: ParseStrategy {
    struct ParseFailure: Error {
        let value: String

        public var description: String {
            "Could not parse date \(value)"
        }

        public var errorDescription: String? {
            description
        }
    }

    func parse(_ value: String) throws -> Date {
        let value = value.removing(charactersIn: .letters)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        if let result = formatter.date(from: value) {
            return result
        }

        if let result = fallbackStrategy(value) {
            return result
        }

        throw ParseFailure(value: value)
    }

    private func fallbackStrategy(_ value: String) -> Date? {
        let regex = try! NSRegularExpression(pattern: "(\\+\\d{2})\\+\\d{4}")

        if let match = regex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.utf16.count)) {

            // Extract the first time zone part
            if let range = Range(match.range(at: 1), in: value) {
                let timeZonePart = value[range]

                // Create the new string by replacing the +XX+XXXX with +XXXX
                let newString = value.replacingOccurrences(of: regex.pattern, with: "\(timeZonePart)00", options: .regularExpression)

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                formatter.locale = Locale(identifier: "en_US_POSIX")

                if let result = formatter.date(from: newString) {
                    return result
                }
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let trimmed = String(value.prefix(19))

        return formatter.date(from: trimmed)
    }
}

extension String {
    func removing(charactersIn set: CharacterSet) -> String {
        components(separatedBy: set).joined()
    }
}
