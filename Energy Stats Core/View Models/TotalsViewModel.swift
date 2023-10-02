//
//  TotalsViewModel.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/08/2023.
//

import Foundation

public struct TotalsViewModel {
    public init(reports: [ReportResponse]) {
        self.home = reports.todayValue(for: ReportVariable.loads)
        self.gridExport = reports.todayValue(for: ReportVariable.feedIn)
        self.gridImport = reports.todayValue(for: ReportVariable.gridConsumption)
        let batteryCharge = reports.todayValue(for: ReportVariable.chargeEnergyToTal)
        let batteryDischarge = reports.todayValue(for: ReportVariable.dischargeEnergyToTal)

        self.solar = max(0, batteryCharge - batteryDischarge - gridImport + home + gridExport)
    }

    public init(grid: Double,
                feedIn: Double,
                loads: Double,
                batteryCharge: Double,
                batteryDischarge: Double) {
        self.home = loads
        self.gridExport = feedIn
        self.gridImport = grid
        self.solar = max(0, batteryCharge - batteryDischarge - gridImport + home + gridExport)
    }

    public var home: Double
    public var gridImport: Double
    public var gridExport: Double
    public var solar: Double
}

private extension Array where Element == ReportResponse {
    func today(for key: ReportVariable) -> ReportResponse.ReportData? {
        guard let currentDateIndex = Calendar.current.dateComponents([.day], from: Date()).day else { return nil }
        return first(where: { $0.variable.lowercased() == key.rawValue.lowercased() })?.data.first(where: { $0.index == currentDateIndex })
    }

    func todayValue(for key: ReportVariable) -> Double {
        today(for: key)?.value ?? 0.0
    }
}
