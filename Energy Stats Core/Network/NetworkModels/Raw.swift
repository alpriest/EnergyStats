//
//  RawResponse.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/09/2022.
//

import Foundation

struct RawRequest: Encodable {
    let deviceID: String
    let variables: [String]
    let timespan = "day"
    let beginDate: QueryDate

    internal init(deviceID: String, variables: [RawVariable], queryDate: QueryDate) {
        self.deviceID = deviceID
        self.variables = variables.map { $0.variable }
        self.beginDate = queryDate
    }
}

public struct RawResponse: Decodable, Hashable {
    public let variable: String
    public let data: [ReportData]

    public struct ReportData: Decodable, Hashable {
        public let time: Date
        public let value: Double

        enum CodingKeys: CodingKey {
            case time
            case value
        }

        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<RawResponse.ReportData.CodingKeys> = try decoder.container(keyedBy: RawResponse.ReportData.CodingKeys.self)
            let timeString = try container.decode(String.self, forKey: RawResponse.ReportData.CodingKeys.time)
            self.time = try Date(timeString, strategy: FoxEssCloudParseStrategy())
            self.value = try container.decode(Double.self, forKey: RawResponse.ReportData.CodingKeys.value)
        }

        init(time: Date, value: Double) {
            self.time = time
            self.value = value
        }
    }
}

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
