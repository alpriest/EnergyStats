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
        self.variables = variables.map { $0.networkTitle }
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
