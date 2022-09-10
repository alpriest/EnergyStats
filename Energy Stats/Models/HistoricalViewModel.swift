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

    init(raw: RawResponse) {
        currentSolarPower = raw.currentValue(for: "pvPower")
        currentGridExport = raw.currentValue(for: "feedinPower")
        currentHomeConsumption = raw.currentValue(for: "loadsPower")
    }
}

extension RawResponse {
    func currentValue(for key: String) -> Double {
        let value: Double

        if let variable = result.first(where: { $0.variable == key }) {
            value = variable.data.last?.value ?? 0.0
        } else {
            value = 0.0
        }

        return value
    }
}

extension Date {
    func currentHour() -> Int? {
        let components = Calendar.current.dateComponents([.hour], from: self)
        return components.hour
    }

    func small() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm:ss"
        return formatter.string(from: self)
    }

    static func todayAt(hour: Int) -> Date {
        Calendar.current.date(bySetting: .hour, value: hour - 1, of: Date())!
    }
}
