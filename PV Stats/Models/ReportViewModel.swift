//
//  ReportViewModel.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct ReportViewModel: Sendable {
    let currentSolarPower: Double
    let currentBatteryLevel: Double
    let gridImport: [PowerTime]
    let gridExport: [PowerTime]

    init(from networkReport: ReportResponse) {
        currentSolarPower = networkReport.currentValue(for: .generation)
        currentBatteryLevel = networkReport.currentValue(for: .feedin)
        gridImport = [PowerTime(date: Date(timeIntervalSince1970: 1662475043), value: 1.0),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475143), value: 1.3),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475243), value: 1.4),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475343), value: 1.2),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475443), value: 0.8),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475543), value: 0.4)
        ]
        gridExport = [PowerTime(date: Date(timeIntervalSince1970: 1662475043), value: 1.0),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475143), value: 1.3),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475243), value: 1.4),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475343), value: 1.2),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475443), value: 0.8),
                      PowerTime(date: Date(timeIntervalSince1970: 1662475543), value: 0.4)
        ]
    }
}

struct PowerTime: Hashable {
    let date: Date
    let value: Double
}

extension ReportResponse {
    func currentValue(for key: HistoryVariableKey) -> Double {
        guard let currentHour = Date().currentHour() else { return 0 }

        let value: Double

        if let variable = result.first(where: { $0.variable == key() }) {
            if let data = variable.data.first(where: { $0.index == currentHour }) {
                value = data.value
            } else {
                value = 0.0
            }
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
}

enum HistoryVariableKey: String {
    case feedin
    case generation
    case gridConsumption
    case chargeEnergyToTal
    case dischargeEnergyToTal
    case loads

    func callAsFunction() -> String {
        rawValue
    }
}

