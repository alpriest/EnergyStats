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
    let beginDate : QueryDate

    internal init(deviceID: String, variables: [String]) {
        self.deviceID = deviceID
        self.variables = variables

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        self.beginDate = QueryDate(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
    }
}

struct RawResponse: Decodable {
    let errno: Int
    let result: [ReportVariable]

    struct ReportVariable: Decodable {
        let variable: String
        let data: [ReportData]
    }

    struct ReportData: Decodable {
        let time: Date
        let value: Double

        enum CodingKeys: CodingKey {
            case time
            case value
        }

        init(from decoder: Decoder) throws {
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
    }

    func parse(_ value: String) throws -> Date {
        let value = value.removing(charactersIn: .letters)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        if let result = formatter.date(from: value) {
            return result
        }

        throw ParseFailure(value: value)
    }
}

extension String {
    func removing(charactersIn set: CharacterSet) -> String {
        components(separatedBy: set).joined()
    }
}
