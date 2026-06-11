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
    public init(reports: [OpenReportResponse], generationViewModel: GenerationViewModel?) {
        let loads = reports.todayValue(for: ReportVariable.loads)
        let feedIn = reports.todayValue(for: ReportVariable.feedIn)
        let gridImport = reports.todayValue(for: ReportVariable.gridConsumption)
        let solar = reports.todayValue(for: ReportVariable.pvEnergyTotal)
        let batteryDischarge = reports.todayValue(for: ReportVariable.dischargeEnergyToTal)
        let batteryCharge = reports.todayValue(for: ReportVariable.chargeEnergyToTal)
        let inverterConsumption = Swift.max((solar + gridImport + batteryDischarge) - (feedIn + batteryCharge + loads), 0)

        self.init(
            grid: gridImport,
            feedIn: feedIn,
            loads: loads,
            solar: solar,
            ct2: generationViewModel?.ct2Total ?? 0,
            inverterConsumption: inverterConsumption
        )
    }

    public init(grid: Double,
                feedIn: Double,
                loads: Double,
                solar: Double,
                ct2: Double,
                inverterConsumption: Double)
    {
        self.home = loads
        self.gridExport = feedIn
        self.gridImport = grid
        self.solar = solar
        self.ct2 = ct2
        self.inverterConsumption = inverterConsumption
    }

    public let home: Double
    public let gridImport: Double
    public let gridExport: Double
    public let solar: Double
    public let ct2: Double
    public let inverterConsumption: Double
}

public extension Array where Element == OpenReportResponse {
    func value(for key: ReportVariable, date: Date) -> OpenReportResponse.ReportData? {
        guard let currentDateIndex = Calendar.current.dateComponents([.day], from: date).day else { return nil }
        return first(where: { $0.variable.lowercased() == key.networkTitle.lowercased() })?.values.first(where: { $0.index == currentDateIndex })
    }
}

public extension Array where Element == OpenReportResponse {
    func todayValue(for key: ReportVariable) -> Double {
        dateValue(for: key, date: Date())
    }
    
    func dateValue(for key: ReportVariable, date: Date) -> Double {
        value(for: key, date: date)?.value ?? 0.0
    }
}
