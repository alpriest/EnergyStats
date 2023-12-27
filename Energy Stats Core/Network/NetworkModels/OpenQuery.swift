//
//  OpenQueryResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 23/12/2023.
//

import Foundation

public struct OpenApiVariable: Decodable {
    let name: String
    let property: Variable

    public struct Variable: Decodable {
        let unit: String
        let name: String
    }
}

public struct OpenQueryResponse: Codable {
    public let time: Date
    public let deviceSN: String
    public let datas: [Data]

    public struct Data: Codable {
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
        let container: KeyedDecodingContainer<OpenQueryResponse.CodingKeys> = try decoder.container(keyedBy: OpenQueryResponse.CodingKeys.self)
        self.datas = try container.decode([Data].self, forKey: CodingKeys.datas)
        let timeString = try container.decode(String.self, forKey: CodingKeys.time)
        self.time = try Date(timeString, strategy: FoxEssCloudParseStrategy())
        self.deviceSN = try container.decode(String.self, forKey: OpenQueryResponse.CodingKeys.deviceSN)
    }

    public init(time: Date, deviceSN: String, datas: [Data]) {
        self.time = time
        self.deviceSN = deviceSN
        self.datas = datas
    }
}

public struct OpenQueryRequest: Encodable {
    public let deviceSN: String?
    public let variables: [String]
}

public struct OpenHistoryRequest: Encodable {
    public let deviceSN: String
    public let variables: [String]
}

public struct OpenHistoryResponse: Decodable {
    public let deviceSN: String
    public let datas: [Data]

    public struct Data: Decodable {
        public let unit: String?
        public let name: String
        public let variable: String
        public let data: [UnitData]

        public struct UnitData: Decodable {
            public let time: Date
            public let value: Double

            enum CodingKeys: CodingKey {
                case time
                case value
            }

            public init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<UnitData.CodingKeys> = try decoder.container(keyedBy: UnitData.CodingKeys.self)
                let timeString = try container.decode(String.self, forKey: CodingKeys.time)
                self.time = try Date(timeString, strategy: FoxEssCloudParseStrategy())
                self.value = try container.decode(Double.self, forKey: UnitData.CodingKeys.value)
            }

            public init(time: Date, value: Double) {
                self.time = time
                self.value = value
            }
        }
    }
}