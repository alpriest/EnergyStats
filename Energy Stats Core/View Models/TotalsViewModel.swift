//
//  TotalsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/08/2023.
//

import Foundation

public struct CalculationBreakdown {
    public let formula: String
    public let calculation: (Int) -> String

    public init(formula: String, calculation: @escaping (Int) -> String) {
        self.formula = formula
        self.calculation = calculation
    }
}

public struct TotalsViewModel {
    public init(reports: [OpenReportResponse]) {
        let home = reports.todayValue(for: ReportVariable.loads)
        let gridExport = reports.todayValue(for: ReportVariable.feedIn)
        let gridImport = reports.todayValue(for: ReportVariable.gridConsumption)
        let batteryCharge = reports.todayValue(for: ReportVariable.chargeEnergyToTal)
        let batteryDischarge = reports.todayValue(for: ReportVariable.dischargeEnergyToTal)

        self.init(grid: gridImport, feedIn: gridExport, loads: home, batteryCharge: batteryCharge, batteryDischarge: batteryDischarge)
    }

    public init(grid: Double,
                feedIn: Double,
                loads: Double,
                batteryCharge: Double,
                batteryDischarge: Double)
    {
        self.home = loads
        self.gridExport = feedIn
        self.gridImport = grid
        self.solar = max(0, batteryCharge - batteryDischarge - gridImport + home + gridExport)
        self.solarBreakdown = CalculationBreakdown(formula: "max(0, batteryCharge - batteryDischarge - gridImport + home + gridExport)",
                                                   calculation: { dp in
                                                       "max(0, \(batteryCharge.roundedToString(decimalPlaces: dp)) - \(batteryDischarge.roundedToString(decimalPlaces: dp)) - \(grid.roundedToString(decimalPlaces: dp)) + \(loads.roundedToString(decimalPlaces: dp)) + \(feedIn.roundedToString(decimalPlaces: dp)))"
                                                   })
    }

    public let home: Double
    public let gridImport: Double
    public let gridExport: Double
    public let solar: Double
    public let solarBreakdown: CalculationBreakdown
}

extension Array where Element == OpenReportResponse {
    func today(for key: ReportVariable) -> OpenReportResponse.ReportData? {
        guard let currentDateIndex = Calendar.current.dateComponents([.day], from: Date()).day else { return nil }
        return first(where: { $0.variable.lowercased() == key.networkTitle.lowercased() })?.values.first(where: { $0.index == currentDateIndex })
    }
}

private extension Array where Element == OpenReportResponse {
    func todayValue(for key: ReportVariable) -> Double {
        today(for: key)?.value ?? 0.0
    }
}
