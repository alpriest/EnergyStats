//
//  StatsGraphValue.swift
//
//
//  Created by Alistair Priest on 09/09/2026.
//

import Energy_Stats_Core
import SwiftUI

struct StatsGraphValue: Identifiable, Hashable {
    let date: Date
    let graphValue: Double
    let type: ReportVariable
    let displayValue: Double?

    var id: String { "\(date.iso8601())_\(type.networkTitle)" }

    init(type: ReportVariable, date: Date, graphValue: Double, displayValue: Double?) {
        self.type = type
        self.date = date
        self.graphValue = graphValue
        self.displayValue = displayValue
    }

    func formatted(_ decimalPlaces: Int) -> String {
        switch type {
        case .selfSufficiency, .batterySOC:
            (displayValue ?? graphValue).percent()
        default:
            (displayValue ?? graphValue).kWh(decimalPlaces)
        }
    }

    var isForNormalGraph: Bool {
        type != .selfSufficiency && type != .inverterConsumption && type != .batterySOC
    }

    var isForSelfSufficiencyGraph: Bool {
        type == .selfSufficiency
    }

    var isForInverterConsumptionGraph: Bool {
        type == .inverterConsumption
    }

    var isForBatterySOCGraph: Bool {
        type == .batterySOC
    }
}
