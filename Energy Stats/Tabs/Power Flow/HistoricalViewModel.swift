//
//  ReportViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct HistoricalViewModel: Sendable {
    let currentSolarPower: Double
    let currentGridExport: Double
    let currentHomeConsumption: Double

    init(raws: [RawResponse]) {
        currentSolarPower = max(0, raws.currentValue(for: RawVariable.batChargePower) - raws.currentValue(for: RawVariable.batDischargePower) - raws.currentValue(for: RawVariable.gridConsumptionPower) + raws.currentValue(for: RawVariable.loadsPower) + raws.currentValue(for: RawVariable.feedinPower))
        currentGridExport = raws.currentValue(for: RawVariable.feedinPower) - raws.currentValue(for: RawVariable.gridConsumptionPower)
        currentHomeConsumption = raws.currentValue(for: RawVariable.gridConsumptionPower) + raws.currentValue(for: RawVariable.generationPower)
    }
}

extension Array where Element == RawResponse {
    func currentValue(for key: RawVariable) -> Double {
        let value: Double

        if let variable = self.first(where: { $0.variable == key.rawValue }) {
            value = variable.data.last?.value ?? 0.0
        } else {
            value = 0.0
        }

        return value
    }
}

extension Date {
    func small() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter.string(from: self)
    }

    func iso8601() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
