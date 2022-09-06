//
//  ReportViewModel.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

struct ReportViewModel {
    let currentSolarPower: Double
    let currentBatteryLevel: Double

    init(from networkReport: ReportResponse) {
        currentSolarPower = networkReport.currentValue(for: .generation)
        currentBatteryLevel = networkReport.currentValue(for: .feedin)
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
}
