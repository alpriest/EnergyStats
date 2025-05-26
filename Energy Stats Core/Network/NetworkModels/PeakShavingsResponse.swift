//
//  Untitled.swift
//  Energy Stats
//
//  Created by Alistair Priest on 25/05/2025.
//

struct PeakShavingRequest: Encodable {
    let sn: String
}

public struct PeakShavingResponse: Decodable {
    public let importLimit: SettingItem
    public let soc: SettingItem

    public init(importLimit: SettingItem, soc: SettingItem) {
        self.importLimit = importLimit
        self.soc = soc
    }
}

public struct SettingItem: Decodable {
    public let precision: Double
    public let range: Range
    public let unit: String
    public let value: String

    public init(precision: Double, range: Range, unit: String, value: String) {
        self.precision = precision
        self.range = range
        self.unit = unit
        self.value = value
    }

    public struct Range: Decodable {
        public let min: Double
        public let max: Double

        public init(min: Double, max: Double) {
            self.min = min
            self.max = max
        }
    }
}
