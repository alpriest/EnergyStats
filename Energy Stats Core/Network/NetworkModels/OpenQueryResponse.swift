//
//  OpenQueryResponse.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 23/12/2023.
//

import Foundation

public struct OpenApiVariableArray: Decodable {
    let array: [OpenApiVariable]

    public init(from decoder: Decoder) throws {
        var apiVariables = [OpenApiVariable]()
        var container = try decoder.unkeyedContainer()

        while !container.isAtEnd {
            let resultDictionary = try container.nestedContainer(keyedBy: DynamicCodingKeys.self)
            for key in resultDictionary.allKeys {
                let yieldData = try resultDictionary.decode(YieldData.self, forKey: key)
                let apiVariable = OpenApiVariable(
                    name: yieldData.name,
                    variable: key.stringValue,
                    unit: yieldData.unit
                )
                apiVariables.append(apiVariable)
            }
        }

        self.array = apiVariables
    }

    struct YieldData: Decodable {
        let unit: String?
        let name: String

        enum CodingKeys: CodingKey {
            case unit
            case name
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<OpenApiVariableArray.YieldData.CodingKeys> = try decoder.container(keyedBy: OpenApiVariableArray.YieldData.CodingKeys.self)
            self.unit = try? container.decode(String.self, forKey: OpenApiVariableArray.YieldData.CodingKeys.unit)
            let names = try container.decode([String: String].self, forKey: OpenApiVariableArray.YieldData.CodingKeys.name)
            self.name = names["en"] ?? "Unknown"
        }
    }
}

public struct OpenApiVariable: Decodable {
    let name: String
    let variable: String
    let unit: String?
}

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
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
    public let sn: String
    public let variables: [String]
    public let begin: Double
    public let end: Double
}

public struct OpenHistoryResponse: Codable {
    public let deviceSN: String
    public let datas: [Data]

    public init(deviceSN: String, datas: [Data]) {
        self.deviceSN = deviceSN
        self.datas = datas
    }

    public struct Data: Codable {
        public let unit: String?
        public let name: String
        public let variable: String
        public let data: [UnitData]

        public struct UnitData: Codable {
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

public struct OpenReportRequest: Encodable {
    let sn: String
    let dimension: ReportType
    let variables: [String]
    let year: Int
    let month: Int?
    let day: Int?

    internal init(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, dimension: ReportType) {
        self.sn = deviceSN
        self.variables = variables.map { $0.networkTitle }
        self.year = queryDate.year
        self.month = queryDate.month
        self.day = queryDate.day
        self.dimension = dimension
    }
}

public struct OpenReportResponse: Codable {
    public let variable: String
    public let unit: String
    public let values: [ReportData]

    enum CodingKeys: CodingKey {
        case variable
        case unit
        case values
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.variable = try container.decode(String.self, forKey: .variable)
        self.unit = try container.decode(String.self, forKey: .unit)
        let doubleValues = try container.decode([Double].self, forKey: .values)
        self.values = doubleValues.enumerated().map { ReportData(index: $0 + 1, value: $1) }
    }

    public struct ReportData: Codable {
        public let index: Int
        public let value: Double
    }
}

public struct GetCurrentSchedulerRequest: Encodable {
    public let deviceSN: String
}

public struct GetSchedulerFlagRequest: Encodable {
    public let deviceSN: String
}

public struct GetSchedulerFlagResponse: Decodable {
    public let enable: Bool
    public let support: Bool
}

public struct SetSchedulerFlagRequest: Encodable {
    public let deviceSN: String
    public let enable: Int
}

public struct SchedulePhaseResponse: Decodable {
    public let enable: Int
    public let startHour: Int
    public let startMinute: Int
    public let endHour: Int
    public let endMinute: Int
    public let workMode: WorkMode
    public let minSocOnGrid: Int
    public let fdSoc: Int
    public let fdPwr: Int?

    enum CodingKeys: CodingKey {
        case enable
        case startHour
        case startMinute
        case endHour
        case endMinute
        case fdPwr
        case workMode
        case fdSoc
        case minSocOnGrid
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.enable = try container.decode(Int.self, forKey: .enable)
        self.startHour = try container.decode(Int.self, forKey: .startHour)
        self.startMinute = try container.decode(Int.self, forKey: .startMinute)
        self.endHour = try container.decode(Int.self, forKey: .endHour)
        self.endMinute = try container.decode(Int.self, forKey: .endMinute)
        self.fdPwr = try container.decodeIfPresent(Int.self, forKey: .fdPwr)
        self.workMode = try container.decode(WorkMode.self, forKey: .workMode)
        self.fdSoc = try container.decode(Int.self, forKey: .fdSoc)
        self.minSocOnGrid = try container.decode(Int.self, forKey: .minSocOnGrid)
    }

    public init(enable: Int, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, workMode: WorkMode, minSocOnGrid: Int, fdSoc: Int, fdPwr: Int?) {
        self.enable = enable
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.workMode = workMode
        self.minSocOnGrid = minSocOnGrid
        self.fdSoc = fdSoc
        self.fdPwr = fdPwr
    }
}

public struct ScheduleResponse: Decodable {
    public let enable: Int
    public let groups: [SchedulePhaseResponse]
}
