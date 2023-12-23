//
//  RealQueryResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 23/12/2023.
//

import Foundation

public struct RealQueryResponse: Decodable {
    public let datas: [RealData]
    public let time: Date
    public let deviceSN: String

    public struct RealData: Decodable {
        let unit: String
        let variable: String
        let value: Double
    }

    enum CodingKeys: CodingKey {
        case datas
        case time
        case deviceSN
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<RealQueryResponse.CodingKeys> = try decoder.container(keyedBy: RealQueryResponse.CodingKeys.self)
        self.datas = try container.decode([RealData].self, forKey: CodingKeys.datas)
        let timeString = try container.decode(String.self, forKey: CodingKeys.time)
        self.time = try Date(timeString, strategy: FoxEssCloudParseStrategy())
        self.deviceSN = try container.decode(String.self, forKey: RealQueryResponse.CodingKeys.deviceSN)
    }

    public init(datas: [RealData], time: Date, deviceSN: String) {
        self.datas = datas
        self.time = time
        self.deviceSN = deviceSN
    }
}

public struct RealQueryRequest: Encodable {
    public let deviceSN: String
    public let variables: [String]
}
